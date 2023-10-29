const bot = require('../../module/bot');
const firestore = require('../../module/firestore');

module.exports.entry = async () => {
    try {
        const guilds = bot.client.guilds.cache;

        for (const fetch of guilds) {
            const guild = fetch[1];
            const channels = guild.channels.cache;

            const collection_guild = firestore.db.collection(`data/guilds/${guild.id}`);
            const doc_guild_info = collection_guild.doc('guild_info');
            await doc_guild_info.set({
                'guild_id': guild.id,
                'guild_name': guild.name,
                'state': true
            });

            let cnt = 0;
            for (const fetch of channels) {
                const channel = fetch[1];

                if (channel.type !== 0) {
                    continue;
                }
                const doc_channel_info = collection_guild.doc(`channels`).collection(`${channel.id}`).doc(`channel_info`);

                await doc_channel_info.set({
                    'channel_id': channel.id,
                    'channel_name': channel.name,
                    'subject': '',
                    'state': true
                });

                cnt++;
            }

            // const doc_room_notify = collection_guild.doc('room_notify');
            // const WEEKS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
            // for (const week of WEEKS) {
            //     await doc_room_notify.set({
            //         week
            //     })
            // }

            await collection_guild.doc(`channels`).set({
                'length': cnt
            })

            console.log('guildInit: Done');
        }
    } catch (error) {
        console.log(error);
    }

}