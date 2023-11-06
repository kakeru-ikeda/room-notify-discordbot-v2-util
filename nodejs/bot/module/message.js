const bot = require('./bot');
const { mode } = require('../mode.json');

module.exports.send = (contents, channel = '') => {
    contents.replace('¥n', "\n");
    console.log(contents);
    if (mode == 'debug') {
        bot.client.channels.cache.get('982998698239852634').send(`${contents}`)
    } else {
        bot.client.channels.cache.get('1097310091276996728').send(`${contents}`) // 教室通知 (本番)
    }
}