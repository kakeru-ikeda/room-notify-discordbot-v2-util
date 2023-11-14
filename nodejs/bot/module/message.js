const bot = require('./bot');
const { mode } = require('../mode.json');
const { EmbedBuilder, GuildScheduledEventManager, Guild, TextChannel } = require('discord.js');

module.exports.send = async ({ contents = '', optionalData, channel = '', isEvent = false, isEmbeds = false, embedsMode }) => {
    console.log(mode);
    console.log(contents);

    const embedsBuilder = (embedsMode, optionalData) => {
        console.log('embedsbuild');
        console.log(optionalData['memo']);
        let embeds;
        if (embedsMode == 'kadai') {
            embeds = new EmbedBuilder()
                .setTitle('【新規課題通知】')
                .setAuthor({ name: optionalData['entry_user_name'], iconURL: optionalData['entry_user_avater'] })
                .setDescription(`${optionalData['subject']}に新規課題が追加されました。`)
                .setThumbnail('https://cdn.discordapp.com/attachments/862951519052627968/966499934440419348/unknown.png')
                .addFields(
                    { name: '科目記号', value: optionalData['subject'] },
                    { name: '課題No.', value: optionalData['kadai_number'] },
                    { name: '課題主題', value: optionalData['kadai_title'] },
                    {
                        name: '納期', value: `${optionalData['deadline'].toDate().toLocaleDateString('ja-JP')} ${optionalData['deadline'].toDate().toLocaleTimeString('ja-JP')}`
                    },
                    { name: '科目担当', value: optionalData['teacher'] },
                    { name: 'メモ', value: optionalData['memo'] != '' ? optionalData['memo'] : ' ' }
                )
                .setTimestamp()
                .setFooter({ text: '教室通知くんv2 license by Lily', iconURL: 'https://cdn.discordapp.com/attachments/862951519052627968/966499934440419348/unknown.png' })
        } else if (embedsMode == 'remind') {
            embeds = new EmbedBuilder()
                .setTitle('【新規リマインド登録】')
                .setAuthor({ name: optionalData['entry_user_name'], iconURL: optionalData['entry_user_avater'], url: 'https://discord.js.org' })
                .setDescription(`リマインドが追加されました。`)
                .setThumbnail('https://cdn.discordapp.com/attachments/862951519052627968/966499934440419348/unknown.png')
                .addFields(
                    { name: '配信チャネル', value: optionalData['subject'] },
                    {
                        name: 'リマインド日時', value: `${optionalData['deadline'].toDate().toLocaleDateString('ja-JP')} ${optionalData['deadline'].toDate().toLocaleTimeString('ja-JP')}`
                    },
                    { name: 'リマインド内容', value: optionalData['memo'] != '' ? optionalData['memo'] : ' ' }
                )
                .setTimestamp()
                .setFooter({ text: '教室通知くんv2 license by Lily', iconURL: 'https://cdn.discordapp.com/attachments/862951519052627968/966499934440419348/unknown.png' })
        }
        return embeds;
    }

    const scheduledEventBuilder = (embedsMode, optionalData) => {
        let event;
        if (embedsMode == 'kadai') {
            event = {
                scheduledStartTime: new Date(optionalData['deadline'].toDate()).setHours(9, 0, 0),
                name: optionalData['kadai_title'],
                description: `課題No.${optionalData['kadai_number']}`,
                privacyLevel: 2,
                entityType: 3,
                scheduledEndTime: optionalData['deadline'].toDate(),
                channel: mode == 'debug'
                    ? bot.client.channels.cache.get('982998698239852634')
                    : bot.client.channels.cache.get(`${channel}`),
                entityMetadata: { location: optionalData['subject'] }
            }
        } else if (embedsMode == 'remind') {
            event = {
                scheduledStartTime: optionalData['deadline'].toDate(),
                name: 'リマインド',
                description: optionalData['memo'],
                privacyLevel: 2,
                entityType: 3,
                scheduledEndTime: new Date(optionalData['deadline'].toDate()).setHours(23, 59, 59),
                channel: mode == 'debug'
                    ? bot.client.channels.cache.get('982998698239852634')
                    : bot.client.channels.cache.get(`${channel}`),
                entityMetadata: { location: optionalData['subject'] }
            }
        }
        return event;
    }

    if (mode == 'debug') {
        if (isEmbeds) {
            const embeds = embedsBuilder(embedsMode, optionalData);
            bot.client.channels.cache.get('982998698239852634').send({ embeds: [embeds] });
        } else {
            bot.client.channels.cache.get('982998698239852634').send(`${contents}`)
        }

        if (isEvent && optionalData != null) {
            await bot.client.guilds.cache.get('982989698567905321').scheduledEvents.create(scheduledEventBuilder(embedsMode, optionalData));
        }
    } else {
        if (isEmbeds) {
            const embeds = embedsBuilder(embedsMode, optionalData);
            bot.client.channels.cache.get(`${channel}`).send({ embeds: [embeds] }) // (本番)
        } else {
            bot.client.channels.cache.get('1097310091276996728').send(`${contents}`) // 教室通知 (本番)
        }

        if (isEvent && optionalData != null) {
            await bot.client.guilds.cache.get(`${optionalData['guildId']}`).scheduledEvents.create(scheduledEventBuilder(embedsMode, optionalData))
        }
    }
}