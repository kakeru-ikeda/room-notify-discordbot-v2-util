import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/page_template.dart';
import 'package:room_notify_discordbot_v2_util/component/style/text_style_template.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class GuildSettingPage extends StatefulWidget {
  const GuildSettingPage({super.key});

  @override
  State<GuildSettingPage> createState() => _GuildSettingPageState();
}

class _GuildSettingPageState extends State<GuildSettingPage> {
  FirebaseFirestore db = FirestoreController.db;
  Future getGuilds() async {
    final docRef = db
        .collection('data')
        .doc('guilds')
        .collection('1094864997164777522')
        .doc('guild_info');
    final docSnapshot = await docRef.get();
    final data = docSnapshot.exists ? docSnapshot.data() : null;

    /* サーバー側からdocumentに情報置いといたほうが楽？（コレクションのリスト取れないのかよ） */
    /* ここでやるとアクセス数エグいかさ増しになるのでmainのinit級にデータ保存する */
    /* discordでのAuthを早いうちに実装したほうが良さげ（ログインしたユーザーと合致するのをギルドから探索。あとfirestoreのルール） */

    print(data!['guild_id']);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() async {
      await getGuilds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '配信ギルド 設定',
              caption: '教室通知くんv2が配信するギルド( = Discordサーバー)を設定します。'),
        ],
      ),
    );
  }
}
