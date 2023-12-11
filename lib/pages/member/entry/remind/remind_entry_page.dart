import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_remind.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/remind/remind_entry_modal_contents.dart';

import '../../../../component/page_template.dart';
import '../../../../controller/firestore_controller.dart';
import '../../../../model/login_user_model.dart';

class RemindEntryPage extends StatefulWidget {
  const RemindEntryPage({super.key});

  @override
  State<RemindEntryPage> createState() => _RemindEntryPageState();
}

class _RemindEntryPageState extends State<RemindEntryPage> {
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
              title: 'リマインド 新規登録',
              caption: '教室通知くんv2からリマインドを設定します。設定日時になると通知が配信されます。'),
          ElevatedButton.icon(
            onPressed: () async {
              showModalBottomSheet<void>(
                context: context,
                constraints: BoxConstraints.expand(),
                enableDrag: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return RemindEntryModalContents(
                    guildId: LoginUserModel.currentGuildId,
                  );
                },
              ).whenComplete(() async {});
            },
            icon: Icon(Icons.add),
            label: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '新しいリマインド',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          StreamBuilder(
            stream: FirestoreController.getReminds(
              guildId: LoginUserModel.currentGuildId,
              isEnabled: true,
            ),
            builder: (context, snapshot) {
              print(snapshot.data);
              if (snapshot.hasData) {
                return SizedBox(
                  height: 500,
                  child: SingleChildScrollView(
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs
                          .map((user) => CardRemind.setCard(
                                guildId: LoginUserModel.currentGuildId,
                                context: context,
                                remindData: user.data(),
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
