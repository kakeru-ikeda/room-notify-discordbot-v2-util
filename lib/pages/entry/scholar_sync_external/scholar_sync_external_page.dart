import 'package:flutter/material.dart';

import '../../../component/page_template.dart';
import '../../../controller/firestore_controller.dart';
import '../../../model/login_user_model.dart';

class ScholarSyncExternalPage extends StatefulWidget {
  const ScholarSyncExternalPage({super.key});

  @override
  State<ScholarSyncExternalPage> createState() =>
      _ScholarSyncExternalPageState();
}

class _ScholarSyncExternalPageState extends State<ScholarSyncExternalPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
            title: 'ScholarSync連携',
            caption: 'ScholarSyncとの連携状態を確認できます。連携は管理者による設定が必要です。',
          ),
          PageTemplate.setGuildInfoTitle(
              guildId: LoginUserModel.currentGuildId),
          const SizedBox(height: 16),
          const Text('ScholarSync連携状態'),
          const SizedBox(height: 8),
          FutureBuilder(
            future: FirestoreController.getScholarSyncStatus(
                guildId: LoginUserModel.currentGuildId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      snapshot.data == true
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.close, color: Colors.red),
                      const SizedBox(width: 8),
                      snapshot.data == true
                          ? const Text('連携済み')
                          : const Text('未連携'),
                    ],
                  );
                } else {
                  return const Text('エラーが発生しました');
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
