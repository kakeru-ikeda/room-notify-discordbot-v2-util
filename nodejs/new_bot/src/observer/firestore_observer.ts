import * as dotenv from 'dotenv'
import { Guild } from 'discord.js';
import admin from 'firebase-admin';
import { FirestoreService } from '../service/firestore_service';
import { MessageService } from '../service/message_service';
import { DoctypeEnum } from '../enum/doctype_enum';
import { Kadai } from '../model/kadai';
import { Remind } from '../model/remind';
import { ScholarSync } from '../model/scholar_sync';

dotenv.config();

export class FirestoreObserver {
    private firestoreService: FirestoreService = new FirestoreService();
    private messageService: MessageService = new MessageService();
    private guild: Guild;
    private debounce: boolean = false;

    constructor(guild: Guild) {
        this.guild = guild;
    }

    private async observeProcess(doctype: DoctypeEnum, change: admin.firestore.DocumentChange<admin.firestore.DocumentData>) {
        /// 通知するドキュメントの種類
        type Doctype = Kadai | Remind | ScholarSync;
        let doc: Doctype;
        let docName: string;

        /// ギルドIDを設定
        const guildId = process.env.MODE == 'DEBUG'
            ? process.env.DEBUG_GUILD_ID
            : this.guild.id;

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
        }

        /// documentの変更に応じて通知する
        if (change.type === 'added') {
            /// 既に通知済みの場合は無視する
            if (change.doc.data()['entry_notify']) {
                console.log(`This ${docName} is already notified`);
                return;
            }

            /// チャネルIDを設定
            this.firestoreService.getCollection({
                collectionId: `data/channels/${guildId}`,
                where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
            }).then(async (channels) => {
                const channelId = process.env.MODE == 'DEBUG'
                    ? process.env.DEBUG_CHANNEL_ID
                    : channels.docs[0].data()['channel_id'];

                /// 通知する
                this.messageService.sendMessage({
                    channel: channelId,
                    embeds: doc.getEmbeds({ changeType: change.type })
                });

                /// scheduleEventsが有効の場合は登録する
                /// docの型がKadaiまたはRemindの場合のみ
                if ((doc instanceof Kadai || doc instanceof Remind) && doc.is_event) {
                    this.messageService.sendScheduleEvent({
                        guildId: guildId!,
                        scheduleData: doc.getScheduledEvent()
                    });
                }

                /// 通知済みにする
                this.debounce = true;
                try {
                    await this.firestoreService.updateDocument({
                        collectionId: doc instanceof ScholarSync
                            ? `notice/external/scholar_sync/guild_id/${process.env.IH13B_GUILD_ID}`
                            : `notice/${docName}/${this.guild.id}`,
                        documentId: change.doc.id,
                        data: { entry_notify: true },
                    });
                } catch (error) {
                    console.error(error);
                }
            });

            console.log(`New ${docName}: `, change.doc.data());
        }
        if (change.type === 'modified') {
            if (this.debounce) {
                this.debounce = false;
                return;
            }

            this.firestoreService.getCollection({
                collectionId: `data/channels/${guildId}`,
                where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
            }).then(async (channels) => {
                const channelId = process.env.MODE == 'DEBUG'
                    ? process.env.DEBUG_CHANNEL_ID
                    : channels.docs[0].data()['channel_id'];

                /// 通知する
                this.messageService.sendMessage({
                    channel: channelId,
                    embeds: doc.getEmbeds({ changeType: change.type })
                });

                /// 通知済みにする
                this.debounce = true;
                try {
                    await this.firestoreService.updateDocument({
                        collectionId: doc instanceof ScholarSync
                            ? `notice/external/scholar_sync/guild_id/${process.env.IH13B_GUILD_ID}`
                            : `notice/${docName}/${this.guild.id}`,
                        documentId: change.doc.id,
                        data: { entry_notify: true },
                    });
                } catch (error) {
                    console.error(error);
                }

                /// todo: scheduleEventsの更新
            });

            console.log(`Modified ${docName}: `, change.doc.data());
        }
        if (change.type === 'removed') {
            this.firestoreService.getCollection({
                collectionId: `data/channels/${guildId}`,
                where: { fieldPath: 'subject', opStr: '==', value: doc.subject }
            }).then(async (channels) => {
                const channelId = process.env.MODE == 'DEBUG'
                    ? process.env.DEBUG_CHANNEL_ID
                    : channels.docs[0].data()['channel_id'];

                /// 通知する
                this.messageService.sendMessage({
                    channel: channelId,
                    embeds: doc.getEmbeds({ changeType: change.type })
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
                this.observeProcess(DoctypeEnum.KADAI, change);
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
                this.observeProcess(DoctypeEnum.REMIND, change);
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
                this.observeProcess(DoctypeEnum.SCHOLAR_SYNC, change);
            });
        });
    }

    public async observe() {
        console.log(`Start firestore observing...`);

        this.onKadaiCreate();
        this.onRemindCreate();
        this.onScholarSyncCreate();
    }
}