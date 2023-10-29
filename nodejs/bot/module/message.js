const bot = require('./bot');
const mode = require('../mode.json');

module.exports.send = (contents, channel = '') => {
    if (mode === 'debug') {
        bot.client.channels.cache.get('982998698239852634').send(contents)
    } else {
        bot.client.channels.cache.get('982998698239852634').send(contents) // channel.id
    }
}