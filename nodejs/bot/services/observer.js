const firestore = require('../module/firestore');

module.exports.listenKadai = () => {

}

module.exports.listenReminds = (guildId) => firestore.db.collection(`notice/remind/${guildId}/`)
    .onSnapshot(querySnapshot => {
        querySnapshot.docChanges().forEach(change => {
            const changeData = change.doc.data();
            if (change.type === 'added') {
                console.log('Add: ', changeData);
                if (changeData['entry_notify']) {
                    return;
                }

                firestore.db.collection(`data/channels/${guildId}/`).where('subject', '==', changeData['subject']).get()
                    .then((res) => {
                        const channelId = res.docs[0].data()['channel_id'];

                    });
            }
            if (change.type === 'modified') {
                console.log('Modified: ', change.doc.data());
            }
            if (change.type === 'removed') {
                console.log('Removed: ', change.doc.data());
            }
        })
    });
