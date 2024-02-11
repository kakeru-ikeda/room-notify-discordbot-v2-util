import { Client, Guild, GuildMember, PartialGuildMember } from 'discord.js';
import { FirestoreService } from '../service/firestore_service';
import { MessageService } from '../service/message_service';
import { client } from '../module/bot';
import { GuildController } from '../controller/guild_controller';
import { FirestoreObserver } from './firestore_observer';

export class GuildObserver {
    private client: Client = client;
    private firestoreService: FirestoreService = new FirestoreService();

    /// 初期化
    public async initialize() {
        /// ギルドの情報
        const guilds = client.guilds.cache;
        console.log(`Connected to ${guilds.size} guilds`);
        console.log(`Guilds: ${guilds.map(g => g.name).join(', ')}`);

        /// エントリーされているギルドに対して初期化処理を行う
        let entrieGuilds: { [key: string]: {} } = {};
        for (const [id, guild] of guilds.entries()) {
            /// 各ギルドの情報
            entrieGuilds[id] = {
                guild_id: guild.id,
                guild_icon: guild.icon,
                guild_name: guild.name,
                room_notify_channel: '',
                state: true
            };

            const guildController = new GuildController(guild);
            await guildController.initializeAll();

            /// FirestoreObserverを起動する
            const firestoreObserver = new FirestoreObserver(guild);
            firestoreObserver.observe();
        }

        /// エントリーされたギルド情報をまとめてFirestoreに保存する
        await this.firestoreService.updateDocument({
            collectionId: 'data',
            documentId: 'guilds',
            data: entrieGuilds,
            isExistsMerge: true
        });

        MessageService.sendLog({ message: '👀 Guilds are initialized. Start observing...' });

        /// 監視を開始する
        this.observe();
    }

    /// ギルドに関するイベントを監視する
    private onGuildCreate() {
        this.client.on('guildCreate', async (guild: Guild) => {
            console.log(`Joined a new guild: ${guild.name}`);
            const guildController = new GuildController(guild);
            await guildController.initializeAll();
        });
    }

    private onGuildDelete() {
        this.client.on('guildDelete', async (guild: Guild) => {
            console.log(`Left a guild: ${guild.name}`);
        });
    }

    private onGuildUnavailable() {
        this.client.on('guildUnavailable', async (guild: Guild) => {
            console.log(`Guild is unavailable: ${guild.name}`);
        });
    }

    /// ギルドメンバーに関するイベントを監視する
    private onGuildMemberAdd() {
        this.client.on('guildMemberAdd', async (member: GuildMember) => {
            console.log(`New member joined: ${member.user.username}`);
            const guild = member.guild;
            const guildController = new GuildController(guild);
            await guildController.initializeMember();
        });
    }

    private onGuildMemberRemove() {
        this.client.on('guildMemberRemove', async (member: GuildMember | PartialGuildMember) => {
            console.log(`Member left: ${member.user.username}`);
        });
    }

    private onGuildMemberUpdate() {
        this.client.on('guildMemberUpdate', async (oldMember: GuildMember | PartialGuildMember, newMember: GuildMember) => {
            console.log(`Member updated: ${newMember.user.username}`);
        });
    }

    /// チャネルに関するイベントを監視する
    private onChannelCreate() {
        this.client.on('channelCreate', async (channel) => {
            console.log(`Channel created: ${channel.id}`);
            const guild = channel.guild;
            const guildController = new GuildController(guild);
            await guildController.channelInitialize();
        });
    }

    private onChannelDelete() {
        this.client.on('channelDelete', async (channel) => {
            console.log(`Channel deleted: ${channel.id}`);
        });
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
}