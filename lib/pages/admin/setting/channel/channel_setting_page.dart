import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../component/page_template.dart';

class ChannelSettingPage extends StatefulWidget {
  const ChannelSettingPage({super.key});

  @override
  State<ChannelSettingPage> createState() => _ChannelSettingPageState();
}

class _ChannelSettingPageState extends State<ChannelSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: 'チャネル 設定',
              caption: '主に課題通知の配信先となる科目チャネルの設定です。Adminユーザーのみ編集可能です。'),
        ],
      ),
    );
  }
}
