import { Client, DMChannel, Guild, GuildMember, NonThreadGuildBasedChannel, PartialGuildMember } from 'discord.js';
import { FirestoreService } from '../service/firestore_service';
import { MessageService } from '../service/message_service';
import { client } from '../module/bot';
import { GuildController } from '../controller/guild_controller';
import { FirestoreObserver } from './firestore_observer';

export class GuildObserver {
    private client: Client;
    private firestoreService: FirestoreService = new FirestoreService();

    constructor() {
        this.client = client;
    }

    /// 初期化
    public async initialize() {
        /// ギルドの情報
        const guilds = client.guilds.cache;
        console.log(`Connected to ${guilds.size} guilds`);
        console.log(`Guilds: ${guilds.map((g) => g.name).join(', ')}`);

        /// エントリーされているギルドに対して初期化処理を行う
        for (const [id, guild] of guilds.entries()) {
            const guildController = new GuildController(guild);
            await guildController.initializeGuild();

            /// FirestoreObserverを起動する
            const firestoreObserver = new FirestoreObserver(guild);
            firestoreObserver.observe();
        }

        /// エントリーギルド情報をupdateする
        await this.setEntryGuild(guilds);

        /// 監視を開始する
        this.observe();

        MessageService.sendLog({
            message: '👀 Guilds are initialized. Start observing...'
        });
    }

    /// エントリー済みのギルド情報をFirestoreに保存する
    private async setEntryGuild(guilds: Map<string, Guild>) {
        let entrieGuilds: { [key: string]: {} } = {};
        for (const [id, guild] of guilds.entries()) {
            entrieGuilds[id] = {
                guild_id: guild.id,
                guild_icon: guild.icon,
                guild_name: guild.name,
                state: true
            };
        }

        await this.firestoreService.setDocument({
            collectionId: 'data',
            documentId: 'guilds',
            data: entrieGuilds
        });
    }

    /// ギルドに関するイベントを監視する
    private guildCreateHandler = async (guild: Guild) => {
        try {
            console.log(`Joined a new guild: ${guild.name}`);
            const guildController = new GuildController(guild);
            await guildController.initializeGuild();
            await this.setEntryGuild(this.client.guilds.cache);
            MessageService.sendLog({
                message: `😘 Joined a new guild: ${guild.name} ( guildId: ${guild.id} )`
            });

            /// 登録時のIncomingメッセージを送信する
            new MessageService().sendMessage({
                channel: guild.systemChannelId!,
                message:
                    '「教室通知くんv2」をサーバーに追加して頂きありがとうございます！\n当Botは、主にHAL東京生向けに展開される、教室通知と課題・リマインド通知を行うBotです。\n専用のユーティリティツールと合わせてご利用ください！\nhttps://room-notify-v2.web.app/'
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while joining a new guild: ${guild.name} ( guildId: ${guild.id} )`
            });
        }
    };

    private onGuildCreate() {
        this.client.on('guildCreate', this.guildCreateHandler);
    }

    private offGuildCreate() {
        this.client.off('guildCreate', this.guildCreateHandler);
    }

    private guildDeleteHandler = async (guild: Guild) => {
        try {
            console.log(`Left a guild: ${guild.name}`);
            this.client = client;

            await this.setEntryGuild(this.client.guilds.cache);
            MessageService.sendLog({
                message: `🥹 Left a guild: ${guild.name} ( guildId: ${guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while leaving a guild: ${guild.name} ( guildId: ${guild.id} )`
            });
        }
    };

    private onGuildDelete() {
        this.client.on('guildDelete', this.guildDeleteHandler);
    }

    private offGuildDelete() {
        this.client.off('guildDelete', this.guildDeleteHandler);
    }

    private guildUnavailableHandler = async (guild: Guild) => {
        try {
            console.log(`Guild is unavailable: ${guild.name}`);
            this.client = client;

            await this.setEntryGuild(this.client.guilds.cache);
            MessageService.sendLog({
                message: `😇 Guild is unavailable: ${guild.name} ( guildId: ${guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while guild is unavailable: ${guild.name} ( guildId: ${guild.id} )`
            });
        }
    };

    private onGuildUnavailable() {
        this.client.on('guildUnavailable', this.guildUnavailableHandler);
    }

    private offGuildUnavailable() {
        this.client.off('guildUnavailable', this.guildUnavailableHandler);
    }

    /// ギルドメンバーに関するイベントを監視する
    private guildMemberAddHandler = async (member: GuildMember) => {
        try {
            console.log(`New member joined: ${member.user.username}`);
            const guildController = new GuildController(member.guild);
            await guildController.addMember(member);
            MessageService.sendLog({
                message: `🏁 ${member.user.displayName} came to the guild! ( guildId: ${member.guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while new member joined: ${member.user.username} ( guildId: ${member.guild.id} )`
            });
        }
    };

    private onGuildMemberAdd() {
        this.client.on('guildMemberAdd', this.guildMemberAddHandler);
    }

    private offGuildMemberAdd() {
        this.client.off('guildMemberAdd', this.guildMemberAddHandler);
    }

    private guildMemberUpdateHandler = async (oldMember: GuildMember | PartialGuildMember, newMember: GuildMember) => {
        try {
            console.log(`Member updated: ${newMember.user.username}`);
            const guildController = new GuildController(newMember.guild);
            await guildController.updateMember(newMember);
            MessageService.sendLog({
                message: `🏁 ${oldMember.displayName} updated his profile to ${newMember.user.username}. ( guildId: ${newMember.guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while member updated: ${newMember.user.username} ( guildId: ${newMember.guild.id} )`
            });
        }
    };

    private onGuildMemberUpdate() {
        this.client.on('guildMemberUpdate', this.guildMemberUpdateHandler);
    }

    private offGuildMemberUpdate() {
        this.client.off('guildMemberUpdate', this.guildMemberUpdateHandler);
    }

    private guildMemberRemoveHandler = async (member: GuildMember | PartialGuildMember) => {
        try {
            console.log(`Member left: ${member.user.username}`);
            const guildController = new GuildController(member.guild);
            await guildController.removeMember(member);
            MessageService.sendLog({
                message: `🏁 ${member.displayName} has left the guild. ( guildId: ${member.guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while member left: ${member.user.username} ( guildId: ${member.guild.id} )`
            });
        }
    };

    private onGuildMemberRemove() {
        this.client.on('guildMemberRemove', this.guildMemberRemoveHandler);
    }

    private offGuildMemberRemove() {
        this.client.off('guildMemberRemove', this.guildMemberRemoveHandler);
    }

    /// チャネルに関するイベントを監視する
    private channelCreateHandler = async (channel: NonThreadGuildBasedChannel) => {
        try {
            console.log(`Channel created: ${channel.id}`);
            const guild = channel.guild;
            const guildController = new GuildController(guild);
            await guildController.addChannel(channel.id, channel.name);
            MessageService.sendLog({
                message: `💍 Channel created! ( guildId: ${guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while channel created: ${channel.id} ( guildId: ${channel.guild.id} )`
            });
        }
    };

    private onChannelCreate() {
        this.client.on('channelCreate', this.channelCreateHandler);
    }

    private offChannelCreate() {
        this.client.off('channelCreate', this.channelCreateHandler);
    }

    private channelDeleteHandler = async (channel: DMChannel | NonThreadGuildBasedChannel) => {
        try {
            console.log(`Channel deleted: ${channel.id}`);
            const guild = (channel as NonThreadGuildBasedChannel).guild;
            const guildController = new GuildController(guild);
            await guildController.removeChannel(channel.id);
            MessageService.sendLog({
                message: `💍 Channel deleted. ( guildId: ${guild.id} )`
            });
        } catch (error) {
            console.error(error);
            MessageService.sendLog({
                message: `🚨 Error occurred while channel deleted: ${channel.id}`
            });
        }
    };

    private onChannelDelete() {
        this.client.on('channelDelete', this.channelDeleteHandler);
    }

    private offChannelDelete() {
        this.client.off('channelDelete', this.channelDeleteHandler);
    }

    /// Observerを起動する
    public observe() {
        this.onGuildCreate();
        this.onGuildDelete();
        this.onGuildUnavailable();
        this.onGuildMemberAdd();
        this.onGuildMemberRemove();
        this.onGuildMemberUpdate();
        this.onChannelCreate();
        this.onChannelDelete();
    }

    /// Observerを停止する
    public stopObserve() {
        this.offGuildCreate();
        this.offGuildDelete();
        this.offGuildUnavailable();
        this.offGuildMemberAdd();
        this.offGuildMemberRemove();
        this.offGuildMemberUpdate();
        this.offChannelCreate();
        this.offChannelDelete();
    }
}
