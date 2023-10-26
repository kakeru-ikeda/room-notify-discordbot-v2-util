import 'package:flutter/material.dart';

import '../../../../component/page_template.dart';

class RoomNotifyEntryPage extends StatefulWidget {
  const RoomNotifyEntryPage({super.key});

  @override
  State<RoomNotifyEntryPage> createState() => _RoomNotifyEntryPageState();
}

class _RoomNotifyEntryPageState extends State<RoomNotifyEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '教室通知 登録・編集',
              caption:
                  '毎日の教室通知の配信を登録します。配信内容の変更や長期休暇時の配信停止の設定もこちらから。Adminユーザーのみ編集可能です。'),
        ],
      ),
    );
  }
}
