import { EmbedBuilder } from 'discord.js';
import { firestore } from 'firebase-admin';

export class Slack {
    public channel_id: string;
    public slack_channel_id: string;
    public slack_channel_name: string;
    public text: string;
    public timestamp: string;
    public user_id: string;
    public user_name: string;
    public team_id: string;
    public team_domain: string;
    public entry_date: string;
    public subject: string;

    constructor(documents: firestore.QueryDocumentSnapshot) {
        const data = documents.data();
        const {
            channel_id,
            slack_channel_id,
            slack_channel_name,
            text,
            timestamp,
            user_id,
            user_name,
            team_id,
            team_domain,
            entry_date,
            subject
        } = data;

        this.channel_id = channel_id;
        this.slack_channel_id = slack_channel_id;
        this.slack_channel_name = slack_channel_name;
        this.text = text;
        this.timestamp = timestamp.replace('.', '');
        this.user_id = user_id;
        this.user_name = user_name;
        this.team_id = team_id;
        this.team_domain = team_domain;
        this.entry_date = `${entry_date.toDate().toLocaleDateString('ja-JP')} ${entry_date.toDate().toLocaleTimeString('ja-JP')}`;
        this.subject = subject;
    }

    public getEmbeds() {
        return new EmbedBuilder()
            .setTitle('【Slack新規通知】')
            .setDescription(`${this.user_name}がSlackに投稿しました。`)
            .setThumbnail(
                'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fslack.png?alt=media'
            )
            .addFields(
                { name: '内容', value: this.text != '' ? this.text : ' ' },
                { name: '日時', value: `${this.entry_date}` },
                { name: '投稿者', value: this.user_name },
                { name: '配信チャネル', value: this.slack_channel_name },
                {
                    name: '投稿URL',
                    value: `https://${this.team_domain}.slack.com/archives/${this.slack_channel_id}/p${this.timestamp}`
                }
            )
            .setColor('#ff1493')
            .setTimestamp()
            .setFooter({
                text: 'Slack連携くん license by Lily',
                iconURL:
                    'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Fslack.png?alt=media'
            });
    }
}
