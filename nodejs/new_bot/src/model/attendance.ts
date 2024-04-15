import * as dotenv from 'dotenv';
import { ColorResolvable, EmbedBuilder } from 'discord.js';
import { firestore } from 'firebase-admin';

dotenv.config();

export class Attendance {
    public title: string;
    public type: string;
    public version?: string;
    public body: string;
    public image_url?: string;
    public access_token: string;
    public debugmode: boolean;

    constructor(documents: firestore.QueryDocumentSnapshot) {
        const data = documents.data();
        const { title, type, version, body, image_url, access_token, debugmode } = data;

        this.title = title;
        this.type = type;
        this.version = version;
        this.body = body;
        this.image_url = image_url;
        this.access_token = access_token;
        this.debugmode = debugmode;
    }

    public getEmbeds() {
        let title: string;
        let description: string;
        let thumbnail: string;
        let color: ColorResolvable;

        switch (this.type) {
            case 'attendance':
                title = '【お知らせ】';
                break;
            case 'release_note':
                title = `リリースノート ver.${this.version}`;
                break;
            default:
                return;
        }

        description = this.title;
        thumbnail =
            'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media';
        color = '#00BFFF';

        const embed =
            this.image_url != 'null'
                ? new EmbedBuilder()
                      .setTitle(title)
                      .setDescription(description)
                      .setColor(color)
                      .setThumbnail(thumbnail)
                      .addFields({ name: '内容', value: this.body })
                      .setImage(this.image_url!)
                      .setTimestamp(new Date())
                      .setFooter({
                          text: '教室通知くんv2 license by Lily',
                          iconURL:
                              'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media'
                      })
                : new EmbedBuilder()
                      .setTitle(title)
                      .setDescription(description)
                      .setColor(color)
                      .setThumbnail(thumbnail)
                      .addFields({ name: '内容', value: this.body })
                      .setTimestamp(new Date())
                      .setFooter({
                          text: '教室通知くんv2 license by Lily',
                          iconURL:
                              'https://firebasestorage.googleapis.com/v0/b/room-notify-v2.appspot.com/o/icons%2Froom_notify.png?alt=media'
                      });

        return embed;
    }
}
