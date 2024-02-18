import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/card_kadai.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/kadai/kadai_entry_modal_contents.dart';

import '../../../component/page_template.dart';

class KadaiEntryPage extends StatefulWidget {
  const KadaiEntryPage({super.key});

  @override
  State<KadaiEntryPage> createState() => _KadaiEntryPageState();
}

class _KadaiEntryPageState extends State<KadaiEntryPage> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '課題 新規登録',
              caption: '教室通知くんv2から課題の提示を配信します。提出期限前になると通知が配信されます。'),
          ElevatedButton.icon(
            onPressed: () async {
              showModalBottomSheet<void>(
                context: context,
                constraints: BoxConstraints.expand(),
                enableDrag: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return KadaiModalContents(
                    guildId: LoginUserModel.currentGuildId,
                  );
                },
              ).whenComplete(() async {});
            },
            icon: Icon(Icons.add),
            label: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '新しい課題',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          StreamBuilder(
            stream: FirestoreController.getKadai(
                guildId: LoginUserModel.currentGuildId, isEnabled: true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: 500,
                  child: SingleChildScrollView(
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs
                          .map((user) => CardKadai.setCard(
                                guildId: LoginUserModel.currentGuildId,
                                context: context,
                                kadaiData: user.data(),
                                deviceWidth: deviceWidth,
                              ))
                          .toList(),
                    ),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }
}
