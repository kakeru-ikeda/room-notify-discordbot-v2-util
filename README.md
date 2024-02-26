# 学生向け総合管理システム「教室通知くん」

![logo](https://github.com/kakeru-ikeda/room-notify-discordbot-v2-util/assets/93127331/1af4db61-e52c-4392-8c13-317cb44549fe)

### 学生の「ナマ」の声から生まれた ”統合管理システム”

「教室通知くん」は、HAL東京に通う学生のQoLを高める目的で開発された統合管理システムです。
学生の「ナマ」の声をもとに、学生の生活をITの支援でより豊かにするための機能を搭載しています。

## 技術構成

 - フロントエンド
   - Flutter v3.10.5
   - Dart v3.0.5
 - バックエンド
   - Node.js v18.19.0
   - TypeScript v5.3.3
   - discord.js v14.13.0
   - node-cron v3.0.2
 - クラウドサービス
   - Google Compute Engine
   - Firebase Cloud Firestore
   - Firebase Cloud Functions
   - Firebase Authentication
   - Firebase Hosting
 - その他
   - Discord API
   - Slack API

## 全体構成図

![structure](https://github.com/kakeru-ikeda/room-notify-discordbot-v2-util/assets/93127331/aae58ec2-8051-4761-ab38-71729e08d335)


## 運用
- [Discord Bot](https://discord.com/api/oauth2/authorize?client_id=1166005725886156860&permissions=8&scope=bot)
- [ユーティリティツール](https://room-notify-v2.web.app/)
- [ユーティリティツール（デモ版）](https://room-notify-v2.web.app//#/auth/?demo=true&id=demouser&email=demo@demo.com&username=DemoUser&global_name=DemoUser&avatar=undefind)
- [プロモーションサイト](https://room-notify-v2-promotion.web.app/)


