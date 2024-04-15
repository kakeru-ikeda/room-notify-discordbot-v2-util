import * as dotenv from 'dotenv';
import { Guild } from 'discord.js';
import admin from 'firebase-admin';
import { FirestoreService } from '../service/firestore_service';
import { MessageService } from '../service/message_service';
import { DoctypeEnum } from '../enum/doctype_enum';
import { Kadai } from '../model/kadai';
import { Remind } from '../model/remind';
import { ScholarSync } from '../model/scholar_sync';
import { Slack } from '../model/slack';
import { Attendance } from '../model/attendance';
import { client } from '../module/bot';

dotenv.config();

export class FirestoreObserver {
    private firestoreService: FirestoreService = new FirestoreService();
    private messageService: MessageService = new MessageService();
    private guild: Guild;
    static debounce: boolean = false;

    constructor(guild: Guild) {
        this.guild = guild;
    }

    private async observeProcess(
        doctype: DoctypeEnum,
        change: admin.firestore.DocumentChange<admin.firestore.DocumentData>
    ) {
        /// 通知するドキュメントの種類
        type Doctype = Kadai | Remind | ScholarSync | Slack;
        let doc: Doctype;
        let docName: string;

        /// ギルドIDを設定
        const guildId = process.env.MODE == 'DEBUG' ? process.env.DEBUG_GUILD_ID : this.guild.id;

        switch (doctype) {
            case DoctypeEnum.KADAI:
                docName = 'kadai';
                doc = new Kadai(change.doc);
                break;
            case DoctypeEnum.REMIND:
                docName = 'remind';
                doc = new Remind(change.doc);
                break;
            case DoctypeEnum.SCHOLAR_SYNC:
                docName = 'scholar_sync';
                doc = new ScholarSync(change.doc);
                break;
            case DoctypeEnum.SLACK:
                docName = 'slack';
                doc = new Slack(change.doc);
                break;
        }

        /// documentの変更に応じて通知する
        if (change.type === 'added') {
            /// 既に通知済みの場合は無視する
            if (change.doc.data()['entry_notify']) {
                console.log(`This ${docName} is already notified`);
                return;
            }

            /// チャネルIDを設定
            this.firestoreService
                .getCollection({
                    collectionId: `data/channels/${guildId}`,
                    where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
                })
                .then(async (channels) => {
                    const channelId =
                        process.env.MODE == 'DEBUG'
                            ? process.env.DEBUG_CHANNEL_ID
                            : channels.docs[0].data()['channel_id'];

                    /// 通知する
                    this.messageService.sendMessage({
                        channel: channelId,
                        embeds: doc.getEmbeds({ changeType: change.type })
                    });
                    MessageService.sendLog({
                        message: `🔥 Added value to firestore. Contents: ${docName} ( guildId: ${guildId} )`
                    });

                    /// scheduleEventsが有効の場合は登録する
                    /// docの型がKadaiまたはRemindの場合のみ
                    if ((doc instanceof Kadai || doc instanceof Remind) && doc.is_event) {
                        this.messageService.sendScheduleEvent({
                            guildId: guildId!,
                            scheduleData: doc.getScheduledEvent()
                        });
                        MessageService.sendLog({
                            message: `⏰ Scheduled events added. Contents: ${docName} ( guildId: ${guildId} )`
                        });
                    }

                    /// 通知済みにする
                    FirestoreObserver.debounce = true;
                    try {
                        await this.firestoreService.updateDocument({
                            collectionId:
                                doc instanceof ScholarSync
                                    ? `notice/external/scholar_sync/guild_id/${process.env.HEW_GUILD_ID}`
                                    : doc instanceof Slack
                                      ? `notice/external/slack/guild_id/${this.guild.id}`
                                      : `notice/${docName}/${this.guild.id}`,
                            documentId: change.doc.id,
                            data: { entry_notify: true }
                        });
                    } catch (error) {
                        MessageService.sendLog({ message: `🚨 ${error}` });
                    }
                });

            console.log(`New ${docName}: `, change.doc.data());
        }
        if (change.type === 'modified') {
            if (FirestoreObserver.debounce) {
                FirestoreObserver.debounce = false;
                return;
            }

            this.firestoreService
                .getCollection({
                    collectionId: `data/channels/${guildId}`,
                    where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
                })
                .then(async (channels) => {
                    const channelId =
                        process.env.MODE == 'DEBUG'
                            ? process.env.DEBUG_CHANNEL_ID
                            : channels.docs[0].data()['channel_id'];

                    /// 通知する
                    this.messageService.sendMessage({
                        channel: channelId,
                        embeds: doc.getEmbeds({ changeType: change.type })
                    });
                    MessageService.sendLog({
                        message: `🔥 Modified value to firestore. Contents: ${docName} ( guildId: ${guildId} )`
                    });

                    /// 通知済みにする
                    FirestoreObserver.debounce = true;
                    try {
                        await this.firestoreService.updateDocument({
                            collectionId:
                                doc instanceof ScholarSync
                                    ? `notice/external/scholar_sync/guild_id/${process.env.HEW_GUILD_ID}`
                                    : doc instanceof Slack
                                      ? `notice/external/slack/guild_id/${this.guild.id}`
                                      : `notice/${docName}/${this.guild.id}`,
                            documentId: change.doc.id,
                            data: { entry_notify: true }
                        });
                    } catch (error) {
                        MessageService.sendLog({ message: `🚨 ${error}` });
                    }

                    /// todo: scheduleEventsの更新
                });

            console.log(`Modified ${docName}: `, change.doc.data());
        }
        if (change.type === 'removed') {
            if (FirestoreObserver.debounce) {
                FirestoreObserver.debounce = false;
                return;
            }

            this.firestoreService
                .getCollection({
                    collectionId: `data/channels/${guildId}`,
                    where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
                })
                .then(async (channels) => {
                    const channelId =
                        process.env.MODE == 'DEBUG'
                            ? process.env.DEBUG_CHANNEL_ID
                            : channels.docs[0].data()['channel_id'];

                    /// 通知する
                    this.messageService.sendMessage({
                        channel: channelId,
                        embeds: doc.getEmbeds({ changeType: change.type })
                    });
                    MessageService.sendLog({
                        message: `🔥 Removed value to firestore. Contents: ${docName} ( guildId: ${guildId} )`
                    });

                    /// todo: scheduleEventsの削除
                });

            console.log(`Removed ${docName}: `, change.doc.data());
        }
    }

    public async onKadaiCreate() {
        const kadaiRef = this.firestoreService.getCollectionRef({
            collectionId: `notice/kadai/${this.guild.id}`,
            where: { fieldPath: 'state', opStr: '==', value: true }
        });

        /// snapshotのdocumentに変更があった場合に発火する
        kadaiRef.onSnapshot((snapshot) => {
            snapshot.docChanges().forEach((change) => {
                try {
                    this.observeProcess(DoctypeEnum.KADAI, change);
                } catch (error) {
                    MessageService.sendLog({ message: `🚨 Error occurred in kadai observer : ${error}` });
                }
            });
        });
    }

    public async onRemindCreate() {
        const remindRef = this.firestoreService.getCollectionRef({
            collectionId: `notice/remind/${this.guild.id}`,
            where: { fieldPath: 'state', opStr: '==', value: true }
        });

        /// snapshotのdocumentに変更があった場合に発火する
        remindRef.onSnapshot((snapshot) => {
            snapshot.docChanges().forEach((change) => {
                try {
                    this.observeProcess(DoctypeEnum.REMIND, change);
                } catch (error) {
                    MessageService.sendLog({ message: `🚨 Error occurred in remind observer : ${error}` });
                }
            });
        });
    }

    public async onScholarSyncCreate() {
        const scholarSyncRef = this.firestoreService.getCollectionRef({
            collectionId: `/notice/external/scholar_sync/guild_id/${this.guild.id}`,
            where: { fieldPath: 'state', opStr: '==', value: true }
        });

        /// snapshotのdocumentに変更があった場合に発火する
        scholarSyncRef.onSnapshot((snapshot) => {
            snapshot.docChanges().forEach((change) => {
                try {
                    this.observeProcess(DoctypeEnum.SCHOLAR_SYNC, change);
                } catch (error) {
                    MessageService.sendLog({ message: `🚨 Error occurred in scholarSync observer : ${error}` });
                }
            });
        });
    }

    public async onSlackCreate() {
        const slackRef = this.firestoreService.getCollectionRef({
            collectionId: `/notice/external/slack/guild_id/${this.guild.id}`
        });

        /// snapshotのdocumentに変更があった場合に発火する
        slackRef.onSnapshot((snapshot) => {
            snapshot.docChanges().forEach((change) => {
                try {
                    this.observeProcess(DoctypeEnum.SLACK, change);
                } catch (error) {
                    MessageService.sendLog({ message: `🚨 Error occurred in slack observer : ${error}` });
                }
            });
        });
    }

    public async onAttendanceCreate() {
        const attendanceRef = this.firestoreService.getCollectionRef({
            collectionId: `notice/attendance/${new Date().getFullYear()}`
        });

        /// snapshotのdocumentに変更があった場合に発火する
        attendanceRef.onSnapshot(async (snapshot) => {
            snapshot.docChanges().forEach(async (change) => {
                try {
                    const doc = new Attendance(change.doc);
                    const guildId: string = process.env.MODE == 'DEBUG' ? process.env.DEBUG_GUILD_ID! : this.guild.id;

                    if (change.type === 'added') {
                        /// 既に通知済みの場合は無視する
                        if (change.doc.data()['entry_notify']) {
                            console.log(`This Attendance is already notified`);
                            return;
                        }

                        /// デバッグモードの場合は指定のギルドのみ通知する
                        if (
                            (process.env.MODE == 'DEBUG' || doc.debugmode) &&
                            this.guild.id != process.env.DEBUG_GUILD_ID
                        ) {
                            return;
                        }

                        this.firestoreService
                            .getCollection({
                                collectionId: `data/channels/${guildId}`
                            })
                            .then(async () => {
                                const guild: Guild = client.guilds.cache.get(guildId)!;

                                this.messageService.sendMessage({
                                    channel: guild.systemChannelId!,
                                    embeds: doc.getEmbeds()
                                });
                                MessageService.sendLog({
                                    message: `🐔 Attendance message sent. (guildId: ${guildId})`
                                });
                            });

                        /// 通知済みにする
                        FirestoreObserver.debounce = true;
                        try {
                            await this.firestoreService.updateDocument({
                                collectionId: `notice/attendance/${new Date().getFullYear()}`,
                                documentId: change.doc.id,
                                data: { entry_notify: true }
                            });
                        } catch (error) {
                            MessageService.sendLog({ message: `🚨 ${error}` });
                        }
                    }
                } catch (error) {
                    MessageService.sendLog({ message: `🚨 Error occurred in attendance observer : ${error}` });
                }
            });
        });
    }

    public async observe() {
        console.log(`Start firestore observing...`);

        this.onKadaiCreate();
        this.onRemindCreate();
        this.onScholarSyncCreate();
        this.onSlackCreate();
        this.onAttendanceCreate();
    }
}
