/* 教室通知：平日授業の教室番号及びZoomURLを提供する */
const bot = require('../module/bot');
const cron = require('node-cron');
const messageController = require('../module/message');

let notice = cron.schedule('* * * * *', () => {
    messageController.send('test');
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