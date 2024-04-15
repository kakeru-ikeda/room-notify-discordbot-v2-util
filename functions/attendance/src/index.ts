import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';

admin.initializeApp();
const app = express();
const db = admin.firestore();

interface Attendance {
    title: string;
    type: Type;
    body: string;
    image_url?: string;
    access_token: string;
    notify?: boolean;
}

const enum Type {
    'attendance',
    'release_note'
}

app.use(express.json())
app.use(express.urlencoded({ extended: true}))

app.post('/', async (request, response) => {
    const requestBody = request.body;
    const body: Attendance = requestBody as Attendance;

    console.log(body.title);

    if (!body.title || !body.body || !body.access_token || !body.type) {
        response.status(400).send("Bad Request");
        return;
    }

    if (body.access_token !== process.env.ACCESS_TOKEN) {
        response.status(403).send("Forbidden");
        return;
    }

    try {
        const collectionName = `notice/attendance/${new Date().getFullYear()}`;
        await db.collection(collectionName).add({
            title: body.title,
            type: body.type,
            body: body.body,
            image_url: body.image_url || 'null',
            timestamp: new Date().getTime(),
            notify: body.notify || true
        });

        response.status(200).send("OK");
    } catch (error) {
        console.error(error);
        response.status(500).send("Internal Server Error");
    }
});

export const attendance = functions.https.onRequest(app);