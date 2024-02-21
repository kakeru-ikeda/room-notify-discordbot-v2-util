import * as dotenv from 'dotenv';
import { EmbedBuilder } from 'discord.js';
import { firestore } from 'firebase-admin';
import { client } from '../module/bot';

dotenv.config();

export class Kadai {
    public attachment: string;
    public deadline: string;
    public entry_date: string;
    public entry_user_avatar: string;
    public entry_user_id: string;
    public entry_user_name: string;
    public guildId: string;
    public is_event: boolean;
    public kadai_number: string;
    public kadai_title: string;
    public memo: string;
    public state: boolean;
    public subject: string;
    public teacher: string;

    constructor(documents: firestore.QueryDocumentSnapshot) {
        const data = documents.data();
        const {
            attachment,
            deadline,
            entry_date,
            entry_user_avatar,
            entry_user_id,
            entry_user_name,
            guildId,
            is_event,
            kadai_number,
            kadai_title,
            memo,
            state,
            subject,
            teacher
        } = data;

        this.attachment = attachment;
        this.deadline = `${deadline.toDate().toLocaleDateString('ja-JP')} ${deadline
            .toDate()
            .toLocaleTimeString('ja-JP')}`;
        this.entry_date = `${entry_date.toDate().toLocaleDateString('ja-JP')} ${entry_date
            .toDate()
            .toLocaleTimeString('ja-JP')}`;
        this.entry_user_avatar = entry_user_avatar;
        this.entry_user_id = entry_user_id;
        this.entry_user_name = entry_user_name;
        this.guildId = guildId;
        this.is_event = is_event;
        this.kadai_number = kadai_number != '' ? kadai_number : '未設定';
        this.kadai_title = kadai_title;
        this.memo = memo != '' ? memo : ' ';
        this.state = state;
        this.subject = subject;
        this.teacher = teacher != '' ? teacher : '未設定';
    }

    public getEmbeds({ changeType }: { changeType: string }) {
        let title: string;
        let description: string;
        let thumbnail: string;

        if (changeType === 'added') {
            title = '【新規課題通知】';
            description = `${this.subject}に新規課題が追加されました。`;
            thumbnail =
                'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media';
        } else if (changeType === 'modified') {
            title = '【課題変更通知】';
            description = `${this.subject}の課題${this.kadai_number}が変更されました。`;
            thumbnail =
                'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fmodified.png?alt=media';
        } else {
            title = '【課題削除通知】';
            description = `${this.subject}の課題${this.kadai_number}が削除されました。`;
            thumbnail =
                'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fremoved.png?alt=media';
        }

        return new EmbedBuilder()
            .setTitle(title)
            .setAuthor({
                name: this.entry_user_name,
                iconURL: this.entry_user_avatar,
                url: 'https://discord.js.org'
            })
            .setDescription(description)
            .setThumbnail(thumbnail)
            .addFields(
                { name: '科目記号', value: this.subject },
                { name: '課題No.', value: this.kadai_number },
                { name: '課題主題', value: this.kadai_title },
                { name: '納期', value: `${this.deadline}` },
                { name: '科目担当', value: this.teacher },
                { name: 'メモ', value: this.memo }
            )
            .setTimestamp()
            .setFooter({
                text: '教室通知くんv2 license by Lily',
                iconURL:
                    'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media'
            });
    }

    public getScheduledEvent() {
        return {
            scheduledStartTime: new Date(this.deadline).setHours(9, 0, 0),
            name: this.kadai_title,
            description: `課題No.${this.kadai_number}`,
            privacyLevel: 2,
            entityType: 3,
            scheduledEndTime: new Date(this.deadline).setHours(23, 59, 59),
            channel:
                process.env.MODE == 'DEBUG'
                    ? client.channels.cache.get(`${process.env.DEBUG_GUILD_ID}`)
                    : client.channels.cache.get(`${this.guildId}`),
            entityMetadata: { location: this.subject }
        };
    }
}
