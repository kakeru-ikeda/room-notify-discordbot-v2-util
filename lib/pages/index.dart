import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:room_notify_discordbot_v2_util/controller/page_controller.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/entry/room_notify/room_notify_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/setting/channel/channel_setting_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/kadai/kadai_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/remind/remind_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/owner/setting/guilld/guild_setting_page.dart';
import 'package:room_notify_discordbot_v2_util/component/common_drawer.dart';

import 'home/home_page.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教室通知くんv2'),
        elevation: 0,
        backgroundColor: Colors.amber,
      ),
      drawer: MediaQuery.of(context).size.width <= 768
          ? const CommonDrawer()
          : null,
      body: Row(
        children: [
          MediaQuery.of(context).size.width > 768
              ? const CommonDrawer()
              : Container(),
          Expanded(
            child: PageView(
              controller: IndexPageController.screen,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomePage(),
                KadaiEntryPage(),
                RemindEntryPage(),
                RoomNotifyEntryPage(),
                ChannelSettingPage(),
                GuildSettingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
