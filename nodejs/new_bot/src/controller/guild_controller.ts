import { Guild } from "discord.js";
import { FirestoreService } from "../service/firestore_service";

export class GuildController {
    private firestoreService: FirestoreService;;
    private guild: Guild;

    constructor(guild: Guild) {
        this.firestoreService = new FirestoreService();
        this.guild = guild;
    }

    public async channelInitialize() {
        const channels = this.guild.channels.cache;
        console.log(`Connected to ${channels.size} channels in ${this.guild.name}`);
        console.log(`Channels: ${channels.map(c => c.name).join(', ')}`);

        for (const [id, channel] of channels.entries()) {
            /// テキストチャネル以外は無視する
            if (channel.type !== 0) {
                continue;
            }

            /// 各チャネルの情報
            const channelData = {
                channel_id: channel.id,
                channel_name: channel.name,
                state: true,
                subject: ''
            };

            /// チャネル情報をFirestoreに保存する
            await this.firestoreService.updateDocument({
                collectionId: `data/channels/${this.guild.id}`,
                documentId: channel.id,
                data: channelData,
                isExistsMerge: true
            });
        }
    }

    public async initializeMember() {
        const members = await this.guild.members.fetch();
        console.log(`Connected to ${members.size} members in ${this.guild.name}`);
        console.log(`Members: ${members.map(m => m.user.username).join(', ')}`);

        for (const [id, member] of members.entries()) {
            /// ボットは無視する
            if (member.user.bot) {
                continue;
            }

            /// 各メンバーの情報
            const memberData = {
                avatar: member.user.avatar,
                user_global_name: member.user.globalName,
                user_id: member.user.id,
                user_name: member.user.username,
                state: true
            };

            /// メンバー情報をFirestoreに保存する
            await this.firestoreService.updateDocument({
                collectionId: `data/users/${this.guild.id}`,
                documentId: member.id,
                data: memberData,
                isExistsMerge: true
            });
        }
    }

    public async initializeRoomNotify() {
        const WEEKDAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
        for (const weekday of WEEKDAYS) {
            let entryRoomNotify: { [key: string]: {} } = {};
            for (let j = 1; j <= 6; j++) {
                entryRoomNotify[j] = {
                    room_number: 0,
                    subject: '',
                    type: '',
                    alert_week: 0,
                    alert_hour: 0,
                    alert_min: 0,
                    zoom_id: '',
                    zoom_pw: '',
                    zoom_url: '',
                    contents: '',
                    state: false
                };
            };

            /// 教室通知情報をFirestoreに保存する
            await this.firestoreService.updateDocument({
                collectionId: `data/notify/${this.guild.id}`,
                documentId: weekday,
                data: entryRoomNotify,
                isExistsMerge: true
            });

            console.log(`Room notify data is created for ${this.guild.name} in ${weekday}`);
        }
    }

    public async initializeAll() {
        await this.channelInitialize();
        await this.initializeMember();
        await this.initializeRoomNotify();
    }
}