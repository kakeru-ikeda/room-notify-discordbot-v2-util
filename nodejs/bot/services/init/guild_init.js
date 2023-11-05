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

            // const collection_guild = firestore.db.collection(`data/guilds/${guild.id}`);
            // const doc_guild_info = collection_guild.doc('guild_info');
            // await doc_guild_info.set({
            //     'guild_id': guild.id,
            //     'guild_name': guild.name,
            //     'guild_icon': guild.icon,
            //     'state': true
            // });

            entryGuilds[guild.id] = {
                'guild_id': guild.id,
                'guild_name': guild.name,
                'guild_icon': guild.icon,
                'state': true
            };

            // let entryChannels = {};
            for (const fetch of channels) {
                const channel = fetch[1];

                if (channel.type !== 0) {
                    continue;
                }

                // entryChannels[channel.id] = {
                //     'channel_id': channel.id,
                //     'channel_name': channel.name,
                //     'subject': '',
                //     'state': true
                // }

                const target = firestore.db.collection(`data/channels/${guild.id}`).doc(channel.id);

                if (!(await (target.get())).exists) {
                    await target.set({
                        'channel_id': channel.id,
                        'channel_name': channel.name,
                        'subject': '',
                        'state': true
                    });
                    console.log(`channel_id  ${channel.id}: Done`);
                } else {
                    console.log(`channel_id  ${channel.id}: Already`);
                }
            }
            // await firestore.db.collection('channels').doc(guild.id).set(entryChannels);

            const users = await guild.members.fetch();

            // let entryUsers = {};
            for (const fetch of users) {
                const user = fetch[1].user;

                if (user.bot) {
                    continue;
                }

                // entryUsers[user.id] = {
                //     'user_id': user.id,
                //     'user_name': user.username,
                //     'discriminator': user.discriminator,
                //     'user_global_name': user.globalName,
                //     'avatar': user.avatar,
                //     'is_admin': false,
                //     'state': true
                // }

                const target = firestore.db.collection(`data/users/${guild.id}`).doc(user.id);

                if (!(await target.get()).exists) {
                    await target.set({
                        'user_id': user.id,
                        'user_name': user.username,
                        'discriminator': user.discriminator,
                        'user_global_name': user.globalName,
                        'avatar': user.avatar,
                        'is_admin': false,
                        'state': true
                    });
                    console.log(`user_id  ${user.id}: Done`);
                } else {
                    console.log(`user_id  ${user.id}: Already`);
                }
            }
            // await firestore.db.collection('users').doc(guild.id).set(entryUsers);

            /* RoomNotify (i: 曜日, j: 時限) */
            const WEEK = { 1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday', 5: 'friday' };
            for (i = 1; i <= 5; i++) {
                const target = firestore.db.collection(`data/room_notify/${guild.id}`).doc(`${WEEK[i]}`);

                if (!(await (target.get())).exists) {
                    let entryRoomNotify = {};
                    for (j = 1; j <= 6; j++) {

                        entryRoomNotify[j] = {
                            'room_number': 0,
                            'subject': '',
                            'type': '',
                            'zoom_id': '',
                            'zoom_pw': '',
                            'zoom_url': '',
                            'contents': '',
                            'state': false
                        }
                    }
                    await target.set(entryRoomNotify);

                    console.log(`room_notify ${guild.id} ${WEEK[i]}: Done`);
                } else {
                    console.log(`room_notify ${guild.id} ${WEEK[i]}: Already`);
                }
            }
        }

        await firestore.db.collection('data').doc('guilds').update(entryGuilds);

        console.log('guildInit: Done');
    } catch (error) {
        console.log(error);
    }

}