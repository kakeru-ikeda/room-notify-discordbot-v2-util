const bot = require('../module/bot');
const cron = require('node-cron');
const messageController = require('../module/message');
const fetchData = require('../model/fetch_data');
const firestore = require('../module/firestore');

let notice = cron.schedule('* * * * *', () => {
    const date = new Date()
    const [year, month, day] = [date.getFullYear(), date.getMonth() + 1, date.getDate()] // 年・月・日
    const [week, hour, minutes] = [date.getDay(), date.getHours(), date.getMinutes()] // 曜・時・分
    // const [week, hour, minutes] = [3, 12, 45]
    // const [year, month, day, week, hour, minutes] = [2023, 11, 15, 3, 21, 0];

    for (const guildKey in fetchData.entryGuilds) {
        console.log(fetchData.entryGuilds[guildKey]);
        const guildData = fetchData.entryGuilds[guildKey];
        const guildId = guildData['guild_id'];

        /* 教室通知：平日授業の教室番号及びZoomURLを提供する */
        for (const roomNotifyKey in fetchData.roomNotify[guildId]) {
            const roomNotifyData = fetchData.roomNotify[guildId][roomNotifyKey];
            console.log(roomNotifyData);
            if (roomNotifyData['alart_week'] == week && roomNotifyData['alart_hour'] == hour && roomNotifyData['alart_min'] == minutes) {
                messageController.send({ contents: roomNotifyData['text'] });
            }
        }

        /* 課題通知：課題の提出日の朝9時と前日の夜21時にリマインドを配信する */
        for (const kadaiKey in fetchData.kadai[guildId]) {
            const kadaiData = fetchData.kadai[guildId][kadaiKey];
            console.log(kadaiData);

            const deadline = kadaiData['deadline'].toDate();
            const [dl_year, dl_month, dl_day, dl_hour, dl_minutes] = [deadline.getFullYear(), deadline.getMonth() + 1, deadline.getDate(), deadline.getHours(), deadline.getMinutes()];

            /* 当日9時の課題通知 */
            if (year == dl_year && month == dl_month && day == dl_day && hour == 9 && minutes == 0) {
                const text = `${kadaiData['subject']} 課題No.${kadaiData['kadai_number']} 「${kadaiData['kadai_title']}」は、本日 ${dl_year}/${dl_month}/${dl_day} ${dl_hour}:${dl_minutes} で提出期限です！`;

                firestore.db.collection(`data/channels/${kadaiData['guildId']}/`).where('subject', '==', kadaiData['subject']).get()
                    .then(async (res) => {
                        const channelId = res.docs[0].data()['channel_id'];
                        messageController.send({ contents: text, channel: channelId })
                    });
            }

            const deadline_yestaday = new Date(deadline.setDate(deadline.getDate() - 1));
            const [dl_yd_year, dl_yd_month, dl_yd_day] = [deadline_yestaday.getFullYear(), deadline_yestaday.getMonth() + 1, deadline_yestaday.getDate()];

            /* 前日21時の課題通知 */
            if (year == dl_yd_year && month == dl_yd_month && day == dl_yd_day && hour == 21 && minutes == 0) {
                const text = `${kadaiData['subject']} 課題No.${kadaiData['kadai_number']} 「${kadaiData['kadai_title']}」は、明日 ${dl_year}/${dl_month}/${dl_day} ${dl_hour}:${dl_minutes} で提出期限です！`;

                firestore.db.collection(`data/channels/${kadaiData['guildId']}/`).where('subject', '==', kadaiData['subject']).get()
                    .then(async (res) => {
                        const channelId = res.docs[0].data()['channel_id'];
                        messageController.send({ contents: text, channel: channelId })
                    });
            }
        }

        /* リマインド：設定日時になるとリマインドを配信する */
        for (const remindKey in fetchData.reminds[guildId]) {
            const remindData = fetchData.reminds[guildId][remindKey];
            console.log(remindData);

            const deadline = remindData['deadline'].toDate();
            const [dl_year, dl_month, dl_day, dl_hour, dl_minutes] = [deadline.getFullYear(), deadline.getMonth() + 1, deadline.getDate(), deadline.getHours(), deadline.getMinutes()];

            /* リマインド通知 */
            if (year == dl_year && month == dl_month && day == dl_day && hour == dl_hour && minutes == dl_minutes) {
                const text = remindData['memo'];

                firestore.db.collection(`data/channels/${remindData['guildId']}/`).where('subject', '==', remindData['subject']).get()
                    .then(async (res) => {
                        const channelId = res.docs[0].data()['channel_id'];
                        messageController.send({ contents: text, channel: channelId })
                    });
            }
        }
    }

    /* 教室通知：平日授業の教室番号及びZoomURLを提供する */
    for (const key in fetchData.roomNotify) {
        // const guild = fetchData.roomNotify[key];
        // for (const guildKey in guild) {
        //     const data = guild[guildKey];
        //     if (data['alart_week'] == week && data['alart_hour'] == hour && data['alart_min'] == minutes) {
        //         messageController.send({ contents: data['text'] });
        //     }
        // }
        /* 課題通知：課題の提出日の朝9時と前日の夜21時にリマインドを配信する */
        // for (const kadaiKey in fetchData.kadai[key]) {
        //     const data = fetchData.kadai[key][kadaiKey];

        //     const deadline = data['deadline'].toDate();
        //     const [dl_year, dl_month, dl_day, dl_hour, dl_minutes] = [deadline.getFullYear(), deadline.getMonth() + 1, deadline.getDate(), deadline.getHours(), deadline.getMinutes()];

        //     /* 当日9時の課題通知 */
        //     if (year == dl_year && month == dl_month && day == dl_day && hour == 9 && minutes == 0) {
        //         const text = `${data['subject']} 課題No.${data['kadai_number']} 「${data['kadai_title']}」は、本日 ${dl_year}/${dl_month}/${dl_day} ${dl_hour}:${dl_minutes} で提出期限です！`;

        //         firestore.db.collection(`data/channels/${data['guildId']}/`).where('subject', '==', data['subject']).get()
        //             .then(async (res) => {
        //                 const channelId = res.docs[0].data()['channel_id'];
        //                 messageController.send({ contents: text, channel: channelId })
        //             });
        //     }

        //     const deadline_yestaday = new Date(deadline.setDate(deadline.getDate() - 1));
        //     const [dl_yd_year, dl_yd_month, dl_yd_day] = [deadline_yestaday.getFullYear(), deadline_yestaday.getMonth() + 1, deadline_yestaday.getDate()];

        //     /* 前日21時の課題通知 */
        //     if (year == dl_yd_year && month == dl_yd_month && day == dl_yd_day && hour == 21 && minutes == 0) {
        //         const text = `${data['subject']} 課題No.${data['kadai_number']} 「${data['kadai_title']}」は、明日 ${dl_year}/${dl_month}/${dl_day} ${dl_hour}:${dl_minutes} で提出期限です！`;

        //         firestore.db.collection(`data/channels/${data['guildId']}/`).where('subject', '==', data['subject']).get()
        //             .then(async (res) => {
        //                 const channelId = res.docs[0].data()['channel_id'];
        //                 messageController.send({ contents: text, channel: channelId })
        //             });
        //     }
        // }
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