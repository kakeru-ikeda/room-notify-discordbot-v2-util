// const admin = require('firebase-admin');
// const functions = require('firebase-functions');
// const ServiceAccount = require('./ServiceAccount.json');

const { Events } = require('discord.js');
const { token } = require('./config.json');
const bot = require('./module/bot');
const fetchData = require('./model/fetch_data');

const notifyRoom = require('./services/notify-room');
const firestore = require('./module/firestore');

const guildInit = require('./services/init/guild_init');

bot.client.once(Events.ClientReady, async c => {
    const text = 'Init\nb'
    bot.client.channels.cache.get('982998698239852634').send(text);
    // guildInit.entry();
    await guildInit.fetch();
    setTimeout(() => { console.log(fetchData.roomNotify); }, 3000)


    // firestore.db.collection('users').doc('TestUser').set({
    //     'name': 'テスト太郎', 'age': 30
    // })
    // const clientInfo = bot.client.guilds.cache.get('982989698567905321');
    // const members = await clientInfo.members.fetch();
    // members.forEach((e) => {
    //     console.log(e.user);
    // })
    // console.log(bot.client.guilds.cache);

    // bot.client.channels.cache.get('982998698239852634').send(members);


    // const res = await firestore.db.collection('data/guilds/IH13B092').get()
    // res.forEach((e) => {
    //     console.log(e.data());
    // })
    // console.log(res);


    notifyRoom.start();
});

bot.client.login(token);