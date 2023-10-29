import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/page_template.dart';
import 'package:room_notify_discordbot_v2_util/component/style/text_style_template.dart';

class GuildSettingPage extends StatefulWidget {
  const GuildSettingPage({super.key});

  @override
  State<GuildSettingPage> createState() => _GuildSettingPageState();
}

class _GuildSettingPageState extends State<GuildSettingPage> {
  // final FirebaseFirestore db = FirebaseFirestore.instance;
  /* firestoreはコンポーネントまとめたほうが扱いやすそう */

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
