import 'package:flutter/material.dart';

import '../../../../component/page_template.dart';

class RemindEntryPage extends StatefulWidget {
  const RemindEntryPage({super.key});

  @override
  State<RemindEntryPage> createState() => _RemindEntryPageState();
}

class _RemindEntryPageState extends State<RemindEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: 'リマインド 新規登録',
              caption: '教室通知くんv2からリマインドを設定します。設定日時になると通知が配信されます。'),
        ],
      ),
    );
  }
}
