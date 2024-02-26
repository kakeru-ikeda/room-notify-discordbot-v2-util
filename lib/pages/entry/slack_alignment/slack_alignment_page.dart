import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_alignment.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/slack_alignment/slack_alignment_modal_contents.dart';

import '../../../component/page_template.dart';
import '../../../controller/firestore_controller.dart';
import '../../../model/login_user_model.dart';

class SlackAlignmentPage extends StatefulWidget {
  const SlackAlignmentPage({super.key});

  @override
  State<SlackAlignmentPage> createState() => _SlackAlignmentPageState();
}

class _SlackAlignmentPageState extends State<SlackAlignmentPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTemplate.setPageTitle(
              title: 'Slack連携',
              caption: 'Slackとの連携設定を行います。',
            ),
            PageTemplate.setGuildInfoTitle(
                guildId: LoginUserModel.currentGuildId),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  constraints: BoxConstraints.expand(),
                  enableDrag: false,
                  builder: (BuildContext context) {
                    return SlackAlignmentModalContents(
                      guildId: LoginUserModel.currentGuildId,
                    );
                  },
                ).whenComplete(() async {});
              },
              icon: Icon(Icons.add),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Slack連携',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            StreamBuilder(
              stream: FirestoreController.getSlackAlignment(
                  guildId: LoginUserModel.currentGuildId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data!.docs);
                  if (snapshot.data!.docs.isNotEmpty) {
                    return SizedBox(
                        height: 500,
                        child: SingleChildScrollView(
                            child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data!.docs
                              .map((data) => CardAlignment.setCard(
                                    guildId: LoginUserModel.currentGuildId,
                                    context: context,
                                    alignmentData: data.data(),
                                  ))
                              .toList(),
                        )));
                  } else {
                    return const Text('連携設定がありません。');
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          ],
        ));
  }
}
