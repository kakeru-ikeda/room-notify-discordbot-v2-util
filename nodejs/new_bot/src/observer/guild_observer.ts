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
        console.log(`Guilds: ${guilds.map(g => g.name).join(', ')}`);

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

        MessageService.sendLog({ message: '👀 Guilds are initialized. Start observing...' });
    }

    /// エントリー済みのギルド情報をFirestoreに保存する
    private async setEntryGuild(guilds: Map<string, Guild>) {
        let entrieGuilds: { [key: string]: {} } = {};
        for (const [id, guild] of guilds.entries()) {
            entrieGuilds[id] = {
                guild_id: guild.id,
                guild_icon: guild.icon,
                guild_name: guild.name,
                room_notify_channel: '',
                state: true
            };
        }

        await this.firestoreService.setDocument({
            collectionId: 'data',
            documentId: 'guilds',
            data: entrieGuilds,
        });
    }

    /// ギルドに関するイベントを監視する
    private guildCreateHandler = async (guild: Guild) => {
        console.log(`Joined a new guild: ${guild.name}`);
        const guildController = new GuildController(guild);
        await guildController.initializeGuild();
        await this.setEntryGuild(this.client.guilds.cache);
    }

    private onGuildCreate() {
        this.client.on('guildCreate', this.guildCreateHandler);
    }

    private offGuildCreate() {
        this.client.off('guildCreate', this.guildCreateHandler);
    }

    private guildDeleteHandler = async (guild: Guild) => {
        console.log(`Left a guild: ${guild.name}`);
        this.client = client;

        await this.setEntryGuild(this.client.guilds.cache);
        // this.stopObserve();
    }

    private onGuildDelete() {
        this.client.on('guildDelete', this.guildDeleteHandler);
    }

    private offGuildDelete() {
        this.client.off('guildDelete', this.guildDeleteHandler);
    }

    private guildUnavailableHandler = async (guild: Guild) => {
        console.log(`Guild is unavailable: ${guild.name}`);
        this.client = client;

        await this.setEntryGuild(this.client.guilds.cache);
        // this.stopObserve();
    }

    private onGuildUnavailable() {
        this.client.on('guildUnavailable', this.guildUnavailableHandler);
    }

    private offGuildUnavailable() {
        this.client.off('guildUnavailable', this.guildUnavailableHandler);
    }

    /// ギルドメンバーに関するイベントを監視する
    private guildMemberAddHandler = async (member: GuildMember) => {
        console.log(`New member joined: ${member.user.username}`);
        const guildController = new GuildController(member.guild);
        await guildController.addMember(member);
    }

    private onGuildMemberAdd() {
        this.client.on('guildMemberAdd', this.guildMemberAddHandler);
    }

    private offGuildMemberAdd() {
        this.client.off('guildMemberAdd', this.guildMemberAddHandler);
    }

    private guildMemberUpdateHandler = async (oldMember: GuildMember | PartialGuildMember, newMember: GuildMember) => {
        console.log(`Member updated: ${newMember.user.username}`);
        const guildController = new GuildController(newMember.guild);
        await guildController.updateMember(newMember);
    }

    private onGuildMemberUpdate() {
        this.client.on('guildMemberUpdate', this.guildMemberUpdateHandler);
    }

    private offGuildMemberUpdate() {
        this.client.off('guildMemberUpdate', this.guildMemberUpdateHandler);
    }

    private guildMemberRemoveHandler = async (member: GuildMember | PartialGuildMember) => {
        console.log(`Member left: ${member.user.username}`);
        const guildController = new GuildController(member.guild);
        await guildController.removeMember(member);
    }

    private onGuildMemberRemove() {
        this.client.on('guildMemberRemove', this.guildMemberRemoveHandler);
    }

    private offGuildMemberRemove() {
        this.client.off('guildMemberRemove', this.guildMemberRemoveHandler);
    }

    /// チャネルに関するイベントを監視する
    private channelCreateHandler = async (channel: NonThreadGuildBasedChannel) => {
        console.log(`Channel created: ${channel.id}`);
        const guild = channel.guild;
        const guildController = new GuildController(guild);
        await guildController.addChannel(channel.id, channel.name);
    }

    private onChannelCreate() {
        this.client.on('channelCreate', this.channelCreateHandler);
    }

    private channelDeleteHandler = async (channel: DMChannel | NonThreadGuildBasedChannel) => {
        console.log(`Channel deleted: ${channel.id}`);
        const guild = (channel as NonThreadGuildBasedChannel).guild;
        const guildController = new GuildController(guild);
        await guildController.removeChannel(channel.id);
    }

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
        this.offChannelDelete();
    }
}