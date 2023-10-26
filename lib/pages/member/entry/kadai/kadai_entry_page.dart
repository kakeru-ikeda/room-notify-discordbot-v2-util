import 'package:flutter/material.dart';

import '../../../../component/page_template.dart';

class KadaiEntryPage extends StatefulWidget {
  const KadaiEntryPage({super.key});

  @override
  State<KadaiEntryPage> createState() => _KadaiEntryPageState();
}

class _KadaiEntryPageState extends State<KadaiEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '課題 新規登録',
              caption: '教室通知くんv2から課題の提示を配信します。提出期限前になると通知が配信されます。'),
        ],
      ),
    );
  }
}
