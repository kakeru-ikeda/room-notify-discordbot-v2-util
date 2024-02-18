import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';

admin.initializeApp();
const app = express();

app.get('/promotion', async (req, res) => {
    const db = admin.firestore();
    const counterRef = db.collection('counters').doc('promotion');
    const increment = admin.firestore.FieldValue.increment(1);
    await counterRef.update({ count: increment });
    res.send(`Promotion counter incremented. Total: ${increment}`);
});

app.get('/detail', async (req, res) => {
    const db = admin.firestore();
    const counterRef = db.collection('counters').doc('detail');
    const increment = admin.firestore.FieldValue.increment(1);
    await counterRef.update({ count: increment });
    res.send(`Detail counter incremented. Total: ${increment}`);
});

export const visitCounter = functions.https.onRequest(app);
