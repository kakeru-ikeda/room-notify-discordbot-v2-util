import * as dotenv from 'dotenv'
import { Events } from "discord.js";
import { CronController } from "./controller/cron_controller";
import { client } from "./module/bot";
import { GuildObserver } from "./observer/guild_observer";
import { MessageService } from './service/message_service';

dotenv.config();

async function main(): Promise<void> {
    if (!process.env.BOT_TOKEN) {
        console.error('BOT_TOKEN is not defined');
        return;
    }
    await client.login(process.env.BOT_TOKEN);
    clientReady();
}

function clientReady() {
    client.once(Events.ClientReady, async () => {
        MessageService.sendLog({ message: '🏃 Client is ready. Start to initialize.' });

        const observer = new GuildObserver();
        const cron = new CronController();
        observer.initialize();
        cron.startTask();
    });
}

main();
