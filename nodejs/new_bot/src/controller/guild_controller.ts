import { ChannelType, Guild, GuildMember, PartialGuildMember } from 'discord.js';
import { FirestoreService } from '../service/firestore_service';

export class GuildController {
    private firestoreService: FirestoreService;
    private guild: Guild;

    constructor(guild: Guild) {
        this.firestoreService = new FirestoreService();
        this.guild = guild;
    }

    public async initializeChannel() {
        const channels = this.guild.channels.cache;
        console.log(`Connected to ${channels.size} channels in ${this.guild.name}`);
        console.log(`Channels: ${channels.map((c) => c.name).join(', ')}`);

        for (const [id, channel] of channels.entries()) {
            /// テキストチャネル以外は無視する
            if (channel.type !== ChannelType.GuildText) {
                continue;
            }

            this.addChannel(channel.id, channel.name);
        }
    }

    public async addChannel(channelId: string, channelName: string) {
        const channelData = {
            channel_id: channelId,
            channel_name: channelName,
            state: true,
            subject: ''
        };

        /// チャネル情報をFirestoreに保存する
        await this.firestoreService.updateDocument({
            collectionId: `data/channels/${this.guild.id}`,
            documentId: channelId,
            data: channelData,
            isExistsMerge: true
        });
    }

    public async removeChannel(channelId: string) {
        /// チャネル情報をFirestoreから削除する
        await this.firestoreService.deleteDocument({
            collectionId: `data/channels/${this.guild.id}`,
            documentId: channelId
        });
    }

    public async initializeMember() {
        const members = await this.guild.members.fetch();
        console.log(`Connected to ${members.size} members in ${this.guild.name}`);
        console.log(`Members: ${members.map((m) => m.user.username).join(', ')}`);

        for (const [id, member] of members.entries()) {
            /// ボットは無視する
            if (member.user.bot) {
                continue;
            }

            this.addMember(member);
        }
    }

    public async addMember(guildMember: GuildMember) {
        const memberData = {
            avatar: guildMember.user.avatar,
            user_global_name: guildMember.user.globalName,
            user_id: guildMember.user.id,
            user_name: guildMember.user.username,
            state: true
        };

        /// メンバー情報をFirestoreに保存する
        await this.firestoreService.updateDocument({
            collectionId: `data/users/${this.guild.id}`,
            documentId: guildMember.id,
            data: memberData,
            isExistsMerge: true
        });
    }

    public async updateMember(guildMember: GuildMember) {
        const memberData = {
            avatar: guildMember.user.avatar,
            user_global_name: guildMember.user.globalName,
            user_id: guildMember.user.id,
            user_name: guildMember.user.username,
            state: true
        };

        /// メンバー情報をFirestoreに保存する
        await this.firestoreService.updateDocument({
            collectionId: `data/users/${this.guild.id}`,
            documentId: guildMember.id,
            data: memberData
        });
    }

    public async removeMember(guildMember: GuildMember | PartialGuildMember) {
        /// メンバー情報をFirestoreから削除する
        await this.firestoreService.deleteDocument({
            collectionId: `data/users/${this.guild.id}`,
            documentId: guildMember.id
        });
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
                    alart_week: 0,
                    alart_hour: 0,
                    alart_min: 0,
                    zoom_id: '',
                    zoom_pw: '',
                    zoom_url: '',
                    contents: '',
                    state: false
                };
            }

            /// 教室通知情報をFirestoreに保存する
            await this.firestoreService.updateDocument({
                collectionId: `data/room_notify/${this.guild.id}`,
                documentId: weekday,
                data: entryRoomNotify,
                isExistsMerge: true
            });

            console.log(`Room notify data is created for ${this.guild.name} in ${weekday}`);
        }
    }

    public async initializeGuild() {
        await this.initializeChannel();
        await this.initializeMember();
        await this.initializeRoomNotify();
    }
}
