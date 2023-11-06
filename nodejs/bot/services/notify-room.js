/* 教室通知：平日授業の教室番号及びZoomURLを提供する */
const bot = require('../module/bot');
const cron = require('node-cron');
const messageController = require('../module/message');
const fetchData = require('../model/fetch_data');

let notice = cron.schedule('* * * * *', () => {
    const date = new Date()
    const [year, month, day] = [date.getFullYear(), date.getMonth() + 1, date.getDate()] // 年・月・日
    // const [week, hour, minutes] = [date.getDay(), date.getHours(), date.getMinutes()] // 曜・時・分
    const [week, hour, minutes] = [2, 9, 20]

    // messageController.send('test');
    for (const key in fetchData.roomNotify) {
        const guild = fetchData.roomNotify[key];
        for (const guildKey in guild) {
            const data = guild[guildKey];
            if (data['alart_week'] == week && data['alart_hour'] == hour && data['alart_min'] == minutes) {
                messageController.send(data['text']);
            }
        }
    }
}, {
    scheduled: false
})

module.exports.start = () => {
    notice.start();
    bot.client.channels.cache.get('982998698239852634').send('Start');
}

module.exports.stop = () => {
    notice.stop()
}