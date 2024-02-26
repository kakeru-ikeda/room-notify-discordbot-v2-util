import * as dotenv from 'dotenv';
import { EmbedBuilder } from 'discord.js';
import { firestore } from 'firebase-admin';

dotenv.config();

export class ScholarSync {
    public entry_date: string;
    public entry_user_avatar: string;
    public entry_user_id: string;
    public entry_user_name: string;
    public guildId: string;
    public memo: string;
    public state: boolean;
    public subject: string;
    public teacher: string;
    public title: string;

    constructor(documents: firestore.QueryDocumentSnapshot) {
        const data = documents.data();
        const {
            entry_date,
            entry_user_avatar,
            entry_user_id,
            entry_user_name,
            guildId,
            memo,
            state,
            subject,
            teacher,
            title
        } = data;

        this.entry_date = `${entry_date.toDate().toLocaleDateString('ja-JP')} ${entry_date.toDate().toLocaleTimeString('ja-JP')}`;
        this.entry_user_avatar = entry_user_avatar;
        this.entry_user_id = entry_user_id;
        this.entry_user_name = entry_user_name;
        this.guildId = guildId;
        this.memo = memo;
        this.state = state;
        this.subject = subject;
        this.teacher = teacher;
        this.title = title;
    }

    public getEmbeds() {
        return new EmbedBuilder()
            .setTitle('【ScholarSync新規通知】')
            .setDescription(`${this.teacher}から新規通知が発行されました。`)
            .setThumbnail(
                'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fscholar_sync.png?alt=media'
            )
            .addFields(
                { name: 'タイトル', value: this.title },
                { name: '日時', value: `${this.entry_date}` },
                { name: '配信チャネル', value: this.subject },
                { name: '本文', value: this.memo != '' ? this.memo : ' ' }
            )
            .setTimestamp()
            .setColor('#4169e1')
            .setFooter({
                text: 'ScholarSync license by naruto1031',
                iconURL:
                    'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fscholar_sync.png?alt=media'
            });
    }
}
