import * as dotenv from 'dotenv'
import { EmbedBuilder } from 'discord.js';
import { firestore } from 'firebase-admin';
import { client } from '../module/bot';

dotenv.config();

export class Remind {
    public attachment: string;
    public deadline: string;
    public entry_date: string;
    public entry_user_avatar: string;
    public entry_user_id: string;
    public entry_user_name: string;
    public guildId: string;
    public is_event: boolean;
    public memo: string;
    public state: boolean;
    public subject: string;

    constructor(documents: firestore.QueryDocumentSnapshot) {
        const data = documents.data();
        const { attachment, deadline, entry_date, entry_user_avatar, entry_user_id, entry_user_name, guildId, is_event, memo, state, subject } = data;

        this.attachment = attachment;
        this.deadline = `${deadline.toDate().toLocaleDateString('ja-JP')} ${deadline.toDate().toLocaleTimeString('ja-JP')}`;
        this.entry_date = `${entry_date.toDate().toLocaleDateString('ja-JP')} ${entry_date.toDate().toLocaleTimeString('ja-JP')}`;
        this.entry_user_avatar = entry_user_avatar;
        this.entry_user_id = entry_user_id;
        this.entry_user_name = entry_user_name;
        this.guildId = guildId;
        this.is_event = is_event;
        this.memo = memo != '' ? memo : ' ';
        this.state = state;
        this.subject = subject;
    }

    public getEmbeds() {
        return new EmbedBuilder()
            .setTitle('【新規リマインド通知】')
            .setAuthor({ name: this.entry_user_name, iconURL: this.entry_user_avatar, url: 'https://discord.js.org' })
            .setDescription(`${this.subject}に新規リマインドが追加されました。`)
            .setThumbnail('https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media')
            .addFields(
                { name: '科目記号', value: this.subject },
                { name: 'リマインド日時', value: `${this.deadline}` },
                { name: 'リマインド内容', value: this.memo }
            )
            .setTimestamp()
            .setFooter({ text: '教室通知くんv2 license by Lily', iconURL: 'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media' });
    }

    public getScheduledEvent() {
        return {
            scheduledStartTime: new Date(this.deadline).setHours(9, 0, 0),
            name: 'リマインド',
            description: this.memo,
            privacyLevel: 2,
            entityType: 3,
            scheduledEndTime: new Date(this.deadline).setHours(23, 59, 59),
            channel: process.env.MODE == 'DEBUG'
                ? client.channels.cache.get(`${process.env.DEBUG_GUILD_ID}`)
                : client.channels.cache.get(`${this.guildId}`),
            entityMetadata: { location: this.subject }
        }
    }
}