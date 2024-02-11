import { EmbedBuilder, Guild, TextChannel } from 'discord.js';
import { client } from '../module/bot';

export class MessageService {
    /**
     * 指定したchannelにメッセージを送信する。messageとembedsは排他的に指定すること。
     * @param channel 配信先のchannelIdを指定
     * @param message メッセージを指定
     * @param embeds embedを指定
     */
    public async sendMessage({ channel, message, embeds }: { channel: string, message?: string, embeds?: EmbedBuilder }) {
        const targetChannel: TextChannel | undefined = client.channels.cache.get(channel) as TextChannel;

        try {
            message == undefined
                ? await targetChannel.send({ embeds: [embeds!] })
                : await targetChannel.send(message);
        } catch (error) {
            console.error(error);
        }
    }

    public async sendScheduleEvent({ guildId, scheduleData }: { guildId: string, scheduleData: any }) {
        const targetGuild: Guild | undefined = client.guilds.cache.get(guildId);

        if (targetGuild == undefined) {
            console.log('Target guild is not found');
            return;
        }

        try {
            await targetGuild.scheduledEvents.create(scheduleData);
        } catch (error) {
            console.error(error);
        }
    }

    public static async sendLog({ message }: { message: string }) {
        const targetChannel: TextChannel | undefined = client.channels.cache.get(process.env.LOG_CHANNEL_ID!) as TextChannel;
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().slice(0, 19).replace("T", " ").replace(/-/g, "/");

        try {
            await targetChannel.send(`[${formattedDate}] ${message}`);
            console.log(message);
        } catch (error) {
            console.error(error);
        }
    }
}