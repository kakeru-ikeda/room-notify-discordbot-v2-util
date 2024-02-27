import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/card_channel.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/channel/channel_modal_contents.dart';

import '../../../component/page_template.dart';
import '../../../controller/firestore_controller.dart';
import '../../../model/login_user_model.dart';

class ChannelSettingPage extends StatefulWidget {
  const ChannelSettingPage({super.key});

  @override
  State<ChannelSettingPage> createState() => _ChannelSettingPageState();
}

class _ChannelSettingPageState extends State<ChannelSettingPage> {
  @override
  Widget build(BuildContext context) {
    List<String> streamList = [];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '配信先チャネル 登録',
              caption: '各種通知の配信先となるチャネルの設定です。教室通知くんは、この設定に従って配信先チャネルを指定できます。'),
          // Guild
          PageTemplate.setGuildInfoTitle(),
          ElevatedButton.icon(
            onPressed: () async {
              showModalBottomSheet<void>(
                context: context,
                constraints: BoxConstraints.expand(),
                enableDrag: false,
                // isScrollControlled: true,
                builder: (BuildContext context) {
                  return ChannelModalContents(
                    guildId: LoginUserModel.currentGuildId,
                  );
                },
              ).whenComplete(() async {});
            },
            icon: Icon(Icons.add),
            label: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '科目追加',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          StreamBuilder(
            stream: FirestoreController.getSubjectEnabledForChannels(
                guildId: LoginUserModel.currentGuildId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return SizedBox(
                    height: 500,
                    child: SingleChildScrollView(
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: snapshot.data!.docs
                            .map((user) => CardChannel.setCard(
                                  guildId: LoginUserModel.currentGuildId,
                                  channelData: user.data(),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                } else {
                  return Text('チャネルがありません');
                }
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
