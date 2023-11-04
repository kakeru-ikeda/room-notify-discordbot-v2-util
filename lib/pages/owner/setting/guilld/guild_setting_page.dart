import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/card_guild.dart';
import 'package:room_notify_discordbot_v2_util/component/page_template.dart';
import 'package:room_notify_discordbot_v2_util/component/style/text_style_template.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

import 'guild_modal_contents.dart';
import '../../../../model/firestore_data_model.dart';

class GuildSettingPage extends StatefulWidget {
  const GuildSettingPage({super.key});

  @override
  State<GuildSettingPage> createState() => _GuildSettingPageState();
}

class _GuildSettingPageState extends State<GuildSettingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '配信ギルド 設定',
              caption: '教室通知くんv2が配信するギルド( = Discordサーバー)を設定します。'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: FirestoreDataModel.entryGuilds!.length,
            itemBuilder: (context, index) {
              // FirestoreDataModel.entryGuilds!['entryGuilds'][index]
              final guildId =
                  FirestoreDataModel.entryGuilds!.keys.elementAt(index);
              final guildIcon =
                  FirestoreDataModel.entryGuilds![guildId]['guild_icon'];
              final guildName =
                  FirestoreDataModel.entryGuilds![guildId]['guild_name'];
              final guildState =
                  FirestoreDataModel.entryGuilds![guildId]['state'];
              print('👑 ${guildId}');
              return InkWell(
                child: CardGuild.setCard(
                  guildId: guildId,
                  guildName: guildName,
                  guildIcon: guildIcon,
                  guildState: guildState,
                ),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    constraints: BoxConstraints.expand(),
                    enableDrag: false,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return GuildModalContents(
                        context: context,
                        guildId: guildId,
                        guildName: guildName,
                        guildIcon: guildIcon,
                        guildState: guildState,
                      );
                    },
                  ).whenComplete(() async {
                    await FirestoreController.getEntryGuilds();
                    Fluttertoast.showToast(msg: '情報を更新しました。');
                    setState(() {});
                  });
                },
              );
            },
          )
        ],
      ),
    );
  }
}
