import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as logger from "firebase-functions/logger";
import * as express from 'express';

admin.initializeApp();
const app = express();
const db = admin.firestore();
const scholarSyncApiKey = process.env.SCHOLAR_SYNC_API_KEY;

interface Slack {
    token: string;
    team_id: string;
    team_domain: string;
    channel_id: string;
    channel_name: string;
    timestamp: number;
    user_id: string;
    user_name: string;
    text: string;
}

interface ScholarSync {
    teacher: string;
    guild_id: string;
    subject: string;
    title: string;
    memo: string;
    state: boolean;
    entry_user_avatar: string;
    entry_user_name: string;
    entry_user_id: string;
    entry_date: number; // Unix Time Stamp
    is_released: boolean;
}

app.use(express.json())
app.use(express.urlencoded({ extended: true}))

app.post('/slack/:guildId/:externalId', async (request, response) => {
    const guildId = request.params.guildId;
    const externalId = request.params.externalId;

    const requestBody = request.body;
    const body: Slack = requestBody as Slack;

    try {
        const collectionName = `data/slack_external/${guildId}`;
        const snapshot = await db.collection(collectionName).doc(externalId).get();
        const data = snapshot.data();

        // error handling: not found
        if (!snapshot.exists) {
            response.status(404).send("Not Found");
            return;
        }
        // error handling: forbidden
        if (data!.slack_token !== body.token) {
            response.status(403).send("Forbidden");
            return;
        }

        const channelId: string = data!.channel_id;
        const slackExternalRef = db.collection(`notice/external/slack/guild_id/${guildId}`).doc();

        await slackExternalRef.set({
            channel_id: channelId,
            slack_channel_name: body.channel_name,
            slack_channel_id: body.channel_id,
            text: body.text,
            timestamp: body.timestamp,
            user_id: body.user_id,
            user_name: body.user_name,
            team_id: body.team_id,
            team_domain: body.team_domain,
            entry_date: new Date(),
            entry_notify: false,
        });

        response.status(200).send('done');
        return;
    } catch (error) {
        logger.error("Error: ", error);
        response.status(500).send("Internal Server Error");
        return;
    }
});

app.post('/scholar_sync', async (request, response) => {
    const apiKey = request.headers["api-key"];

  if (!apiKey || apiKey !== scholarSyncApiKey) {
    response.status(403).send("not authorized");
    return;
  }

  try {
    const requestData: ScholarSync = request.body;
    const subjectCollectionName = `data/channels/${requestData.guild_id}`;
    const subjectData = await db.collection(subjectCollectionName).get();
    const isExistSubject = subjectData.docs.some(
      (doc) => doc.data()?.subject === requestData.subject
    );
    if (!isExistSubject) {
      response.status(400).send("Bad Request");
      return;
    }

    const collectionName = `notice/external/scholar_sync/guild_id/${requestData.guild_id}`;
    const doc = await db.collection(collectionName).add({
      teacher: requestData.teacher,
      guildId: requestData.guild_id,
      subject: requestData.subject,
      title: requestData.title,
      memo: requestData.memo,
      state: requestData.state,
      entry_user_avater: requestData.entry_user_avatar,
      entry_user_name: requestData.entry_user_name,
      entry_user_id: requestData.entry_user_id,
      entry_date: new Date(requestData.entry_date),
      is_released: requestData.is_released,
    });
    console.log(`Document written with ID: ${doc.id}`);
    response.status(200).send(`Document written with ID: ${doc.id}`);
  } catch (error) {
    logger.error("Error: ", error);
    response.status(500).send("Internal Server Error");
    return;
  }
});

export const external = functions.https.onRequest(app);