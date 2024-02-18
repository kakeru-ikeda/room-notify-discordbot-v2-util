// import { config } from 'dotenv';
import * as functions from 'firebase-functions';
import * as express from 'express';

// config();
const app = express();

async function getTokenResponse(isRelease: boolean, code: string): Promise<any> {
    const tokenResponse: Response = await fetch('https://discord.com/api/v10/oauth2/token', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            client_id: process.env.DISCORD_CLIENT_ID as string,
            client_secret: process.env.DISCORD_CLIENT_SECRET as string,
            code: code,
            grant_type: 'authorization_code',
            redirect_uri: isRelease
                ? process.env.BOT_REDIRECT_URI_RELEASE as string
                : process.env.BOT_REDIRECT_URI_DEVELOP as string
        })
    });

    return await tokenResponse.json();
}

function getRedirectUrl(isRelease: boolean, userData: any): string {
    const userId = userData["id"];
    const email = userData["email"];
    const username = userData["username"];
    const global_name = userData["global_name"];
    const avatar = userData["avatar"];

    return isRelease
        ? 'https://room-notify-v2.web.app/#/auth/?id=' + userId + '&email=' + email + '&username=' + username + '&global_name=' + global_name + '&avatar=' + avatar
        : 'http://localhost:5555/#/auth/?id=' + userId + '&email=' + email + '&username=' + username + '&global_name=' + global_name + '&avatar=' + avatar;
}


app.get('/release', async (req, res) => {
    const code = req.query.code as string; // Discordからの認証コード

    // DiscordのTokenエンドポイントにPOSTリクエストを送信してアクセストークンを取得
    const tokenData = await getTokenResponse(true, code);
    const accessToken = tokenData.access_token;

    // DiscordのAPIを使用してユーザー情報を取得
    const userResponse = await fetch('https://discord.com/api/v10/users/@me', {
        headers: {
            authorization: `Bearer ${accessToken}`
        }
    });
    const userData = await userResponse.json();

    const redirectUrl: string = getRedirectUrl(true, userData);

    res.redirect(redirectUrl);
});

app.get('/develop', async (req, res) => {
    const code = req.query.code as string; // Discordからの認証コード

    // DiscordのTokenエンドポイントにPOSTリクエストを送信してアクセストークンを取得
    const tokenData = await getTokenResponse(false, code);
    const accessToken = tokenData.access_token;

    // DiscordのAPIを使用してユーザー情報を取得
    const userResponse = await fetch('https://discord.com/api/v10/users/@me', {
        headers: {
            authorization: `Bearer ${accessToken}`
        }
    });
    const userData = await userResponse.json();

    const redirectUrl: string = getRedirectUrl(false, userData);

    res.redirect(redirectUrl);
});

export const discordAuth = functions.https.onRequest(app);
