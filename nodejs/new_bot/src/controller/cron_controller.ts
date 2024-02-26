import * as dotenv from 'dotenv';
import cron from 'node-cron';
import { FirestoreObserver } from '../observer/firestore_observer';
import { FirestoreService } from '../service/firestore_service';
import { MessageService } from '../service/message_service';
import { Kadai } from '../model/kadai';
import { Remind } from '../model/remind';

dotenv.config();

export class CronController {
    private firestoreService: FirestoreService = new FirestoreService();
    private messageService: MessageService = new MessageService();
    private date: Date = new Date();

    private cronTime: string = '* * * * *';
    private task: () => void = async () => {
        this.date = new Date();
        // this.date = new Date('2024-02-12 09:00:00');
        const [week, hour, minutes] = [this.date.getDay(), this.date.getHours(), this.date.getMinutes()]; // 曜・時・分

        /// エントリーギルド情報を取得する
        const entryGuild = await this.firestoreService.getDocument({
            collectionId: 'data',
            documentId: 'guilds'
        });

        /// entryGuildの内容の数だけループ
        for (const [key, value] of Object.entries(entryGuild.data()!)) {
            const guildId = key;

            /// 教室通知: 平日授業の教室番号及びZoomURLを配信する
            /// 土日はスキップ
            if (week <= 5) {
                this.roomNotify(guildId);
            }

            /// 課題通知: 課題の提出日の朝9時と前日の夜21時にリマインドを配信する
            this.kadaiNotify(guildId);

            /// リマインド通知: リマインドの時刻にリマインドを配信する
            this.remindNotify(guildId);
        }
    };

    private roomNotify = async (guildId: string) => {
        const [week, hour, minutes] = [this.date.getDay(), this.date.getHours(), this.date.getMinutes()]; // 曜・時・分

        /// 教室通知を配信するチャネルを取得
        let roomNotifyChannel: string = '';
        await this.firestoreService
            .getDocument({
                collectionId: 'data/room_notify/notify_channel',
                documentId: 'default'
            })
            .then((doc) => {
                try {
                    roomNotifyChannel = doc.data()![guildId]['channel_id'];
                } catch (error) {
                    roomNotifyChannel = process.env.DEBUG_CHANNEL_ID!;
                }
            });

        /// 教室通知情報を取得する
        await this.firestoreService
            .getCollection({
                collectionId: `data/room_notify/${guildId}`
            })
            .then((querySnapshot) => {
                querySnapshot.forEach((doc) => {
                    for (const [key, value] of Object.entries(doc.data())) {
                        /// 現在時刻が設定された時間と一致した場合はリマインドを配信する
                        if (
                            value['state'] &&
                            value['alart_week'] == week &&
                            value['alart_hour'] == hour &&
                            value['alart_min'] == minutes
                        ) {
                            this.messageService.sendMessage({
                                channel:
                                    process.env.MODE == 'DEBUG' ? process.env.DEBUG_CHANNEL_ID! : roomNotifyChannel,
                                message: value['text']
                            });
                            MessageService.sendLog({
                                message: `🏫 room notify has been sent to guild ID: ${guildId}.`
                            });
                        }
                    }
                });
            });
    };

    private kadaiNotify = async (guildId: string) => {
        const [year, month, day] = [this.date.getFullYear(), this.date.getMonth() + 1, this.date.getDate()]; // 年・月・日
        const [hour, minutes] = [this.date.getHours(), this.date.getMinutes()]; // 時・分

        /// 課題通知情報を取得する
        await this.firestoreService
            .getCollection({
                collectionId: `notice/kadai/${guildId}`
            })
            .then((querySnapshot) => {
                querySnapshot.forEach(async (doc) => {
                    const kadai = new Kadai(doc);

                    /// 当日の朝9時にリマインドを配信する
                    const deadline = new Date(kadai.deadline);
                    const [d_year, d_month, d_day] = [
                        deadline.getFullYear(),
                        deadline.getMonth() + 1,
                        deadline.getDate()
                    ]; // 年・月・日
                    const [d_hour, d_minutes] = [deadline.getHours(), deadline.getMinutes()]; // 時・分

                    if (year == d_year && month == d_month && day == d_day && hour == 9 && minutes == 0) {
                        const message =
                            kadai.kadai_number != ''
                                ? `${kadai.subject} 課題No.${kadai.kadai_number} 「${kadai.kadai_title}」の提出期限は、本日 ${d_year}/${d_month}/${d_day} ${d_hour}:${d_minutes} です！`
                                : `${kadai.subject} 「${kadai.kadai_title}」の提出期限は、本日 ${d_year}/${d_month}/${d_day} ${d_hour}:${d_minutes} です！`;

                        /// 課題通知を配信するチャネルを取得
                        await this.firestoreService
                            .getCollection({
                                collectionId: `data/channels/${guildId}`,
                                where: { fieldPath: 'subject', opStr: '==', value: kadai.subject }
                            })
                            .then((channels) => {
                                /// チャネルにリマインドを配信
                                this.messageService.sendMessage({
                                    channel:
                                        process.env.MODE == 'DEBUG'
                                            ? process.env.DEBUG_CHANNEL_ID!
                                            : channels.docs[0].data()['channel_id'],
                                    message: message
                                });
                                MessageService.sendLog({
                                    message: `🧑‍💻 Today's kadai notify was sent to guild ID: ${guildId}.`
                                });
                            });
                    }

                    /// 当日の課題締め切り時刻になったらstateをfalseにする
                    if (year == d_year && month == d_month && day == d_day && hour == d_hour && minutes == d_minutes) {
                        FirestoreObserver.debounce = true;
                        await this.firestoreService.updateDocument({
                            collectionId: `notice/kadai/${guildId}`,
                            documentId: doc.id,
                            data: { state: false }
                        });
                        MessageService.sendLog({
                            message: `💀 Guild ID: ${guildId} kadai has reached its deadline. ( ${kadai.kadai_title} )`
                        });
                    }

                    /// 前日の夜21時にリマインドを配信する
                    const deadline_yesterday = new Date(deadline.setDate(deadline.getDate() - 1));
                    const [dy_year, dy_month, dy_day] = [
                        deadline_yesterday.getFullYear(),
                        deadline_yesterday.getMonth() + 1,
                        deadline_yesterday.getDate()
                    ]; // 年・月・日
                    const [dy_hour, dy_minutes] = [deadline_yesterday.getHours(), deadline_yesterday.getMinutes()]; // 時・分

                    if (year == dy_year && month == dy_month && day == dy_day && hour == 21 && minutes == 0) {
                        const message =
                            kadai.kadai_number != ''
                                ? `${kadai.subject} 課題No.${kadai.kadai_number} 「${kadai.kadai_title}」の提出期限は、明日 ${dy_year}/${dy_month}/${dy_day} ${dy_hour}:${dy_minutes} です！`
                                : `${kadai.subject} 「${kadai.kadai_title}」の提出期限は、明日 ${dy_year}/${dy_month}/${dy_day} ${dy_hour}:${dy_minutes} です！`;

                        /// 課題通知を配信するチャネルを取得
                        await this.firestoreService
                            .getCollection({
                                collectionId: `data/channels/${guildId}`,
                                where: { fieldPath: 'subject', opStr: '==', value: kadai.subject }
                            })
                            .then((channels) => {
                                /// チャネルにリマインドを配信
                                this.messageService.sendMessage({
                                    channel:
                                        process.env.MODE == 'DEBUG'
                                            ? process.env.DEBUG_CHANNEL_ID!
                                            : channels.docs[0].data()['channel_id'],
                                    message: message
                                });
                                MessageService.sendLog({
                                    message: `🧑‍💻 The next day's kadai notify was sent to guild ID: ${guildId}.`
                                });
                            });
                    }
                });
            });
    };

    private remindNotify = async (guildId: string) => {
        const [year, month, day] = [this.date.getFullYear(), this.date.getMonth() + 1, this.date.getDate()]; // 年・月・日
        const [hour, minutes] = [this.date.getHours(), this.date.getMinutes()]; // 時・分

        /// リマインド通知情報を取得する
        await this.firestoreService
            .getCollection({
                collectionId: `notice/remind/${guildId}`
            })
            .then((querySnapshot) => {
                querySnapshot.forEach((doc) => {
                    const remind = new Remind(doc);

                    /// 当日のリマインド時刻にリマインドを配信する
                    const deadline = new Date(remind.deadline);
                    const [d_year, d_month, d_day] = [
                        deadline.getFullYear(),
                        deadline.getMonth() + 1,
                        deadline.getDate()
                    ]; // 年・月・日
                    const [d_hour, d_minutes] = [deadline.getHours(), deadline.getMinutes()]; // 時・分

                    if (year == d_year && month == d_month && day == d_day && hour == d_hour && minutes == d_minutes) {
                        const message = remind.memo;

                        /// リマインド通知を配信するチャネルを取得
                        this.firestoreService
                            .getCollection({
                                collectionId: `data/channels/${guildId}`,
                                where: { fieldPath: 'subject', opStr: '==', value: remind.subject }
                            })
                            .then((channels) => {
                                /// チャネルにリマインドを配信
                                this.messageService.sendMessage({
                                    channel:
                                        process.env.MODE == 'DEBUG'
                                            ? process.env.DEBUG_CHANNEL_ID!
                                            : channels.docs[0].data()['channel_id'],
                                    message: message
                                });
                                MessageService.sendLog({
                                    message: `🎗️ A reminder has been sent to guild ID: ${guildId}.`
                                });
                            });
                    }
                });
            });
    };

    private scheduleTask = () => {
        return cron.schedule(this.cronTime, this.task, { scheduled: false });
    };

    public startTask() {
        this.scheduleTask().start();
    }

    public stopTask() {
        this.scheduleTask().stop();
    }
}
