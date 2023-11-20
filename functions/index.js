/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// exports.authRedirect = onRequest((request, response) => {
//     logger.info("Hello logs!", { structuredData: true });
//     // response.send("Hello from Firebase!");
//     let r = response.redirect(301, "https://discord.com/api/oauth2/authorize?client_id=1166005725886156860&redirect_uri=https%3A%2F%2Fauthredirect-at6en6psyq-uc.a.run.app&response_type=code&scope=identify");
//     logger.info(r);
// });

const functions = require('firebase-functions');
const express = require('express');

const app = express();

app.get('/discord-redirect', async (req, res) => {
    const code = req.query.code; // Discordからの認証コード

    // DiscordのTokenエンドポイントにPOSTリクエストを送信してアクセストークンを取得
    const tokenResponse = await fetch('https://discord.com/api/v10/oauth2/token', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            client_id: '1166005725886156860',
            client_secret: '8D80bUhN9cJhHHK1L2gXVFD8ZteZ_LxD',
            code: code,
            grant_type: 'authorization_code',
            redirect_uri: 'https://us-central1-room-notify-v2.cloudfunctions.net/discordAuth/discord-redirect'
        })
    });

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;

    // DiscordのAPIを使用してユーザー情報を取得
    const userResponse = await fetch('https://discord.com/api/v10/users/@me', {
        headers: {
            authorization: `Bearer ${accessToken}`
        }
    });

    const userData = await userResponse.json();

    // ユーザー情報をFirebaseやデータベースに保存するなど、必要な処理を行う

    res.send(userData); // ユーザー情報をレスポンスとして返す（サンプル）

});

exports.discordAuth = functions.https.onRequest(app);
