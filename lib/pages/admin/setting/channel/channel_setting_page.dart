import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/card_channel.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/setting/channel/channel_modal_contents.dart';

import '../../../../component/page_template.dart';
import '../../../../controller/firestore_controller.dart';
import '../../../../model/login_user_model.dart';

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
              title: 'チャネル 設定',
              caption: '課題通知とリマインドの配信先となるチャネルの設定です。Adminユーザーのみ編集可能です。'),
          // Guild
          PageTemplate.setGuildInfoTitle(),
          StreamBuilder(
            stream: FirestoreController.getGuildChannels(
                guildId: LoginUserModel.currentGuildId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return SizedBox(
                    height: 600,
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
