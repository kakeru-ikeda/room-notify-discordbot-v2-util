const { log } = require('console');
const bot = require('../../module/bot');
const firestore = require('../../module/firestore');

module.exports.entry = async () => {
    try {
        const guilds = bot.client.guilds.cache;
        let entryGuilds = {};

        for (const fetch of guilds) {
            const guild = fetch[1];
            const channels = guild.channels.cache;

            console.log(guild);

            const collection_guild = firestore.db.collection(`data/guilds/${guild.id}`);
            const doc_guild_info = collection_guild.doc('guild_info');
            await doc_guild_info.set({
                'guild_id': guild.id,
                'guild_name': guild.name,
                'guild_icon': guild.icon,
                'state': true
            });

            entryGuilds[guild.id] = {
                'guild_name': guild.name,
                'guild_icon': guild.icon,
                'state': true
            };

            let entryChannels = {};
            for (const fetch of channels) {
                const channel = fetch[1];

                if (channel.type !== 0) {
                    continue;
                }

                entryChannels[channel.id] = {
                    'channel_name': channel.name,
                    'subject': '',
                    'state': true
                };
            }
            await collection_guild.doc(`channels`).set(entryChannels);

            const users = await guild.members.fetch();

            let entryUsers = {};
            for (const fetch of users) {
                const user = fetch[1].user;

                if (user.bot) {
                    continue;
                }

                entryUsers[user.id] = {
                    'user_id': user.id,
                    'user_name': user.username,
                    'discriminator': user.discriminator,
                    'user_global_name': user.globalName,
                    'avatar': user.avatar,
                    'state': true
                };
            }
            await collection_guild.doc(`users`).set(entryUsers);
        }

        await firestore.db.collection('data').doc('guilds').set(entryGuilds)

        console.log('guildInit: Done');
    } catch (error) {
        console.log(error);
    }

}