import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/controller/page_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/entry/room_notify/room_notify_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/entry/teacher/teacher_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/entry/channel/channel_setting_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/kadai/kadai_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/remind/remind_entry_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/owner/setting/guilld/guild_setting_page.dart';
import 'package:room_notify_discordbot_v2_util/component/common_drawer.dart';

import '../controller/firestore_controller.dart';
import '../model/firestore_data_model.dart';
import '../model/firestore_data_model.dart';
import 'home/home_page.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future(
      () async {
        // await FirestoreController.getEntryGuilds();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      List userEntryGuild = [];
      bool isEntry = false;

      await FirestoreController.getEntryGuilds();
      if (user != null) {
        print('👑 ${LoginUserModel.userId}');
        for (String guildId in FirestoreDataModel.entryGuilds!.keys) {
          final userDocData = await FirestoreController.getGuildEntryUser(
            guildId: guildId,
            userId: LoginUserModel.userId,
          );
          print('👑 PAPAPA');

          if (userDocData.exists &&
              userDocData.data()!['user_id'] == LoginUserModel.userId) {
            isEntry = true;
            print(guildId);
            userEntryGuild.add(guildId);
          }

          userEntryGuild.sort(((a, b) => a.compareTo(b)));
          final guildDocData = await FirestoreController.getGuildData();
          print(guildDocData.data());
          final currentGuildName = guildDocData
              .data()![userEntryGuild.first.toString()]['guild_name'];

          await FirestoreController.setLoginUserData(
            uid: user.uid,
            currentGuildId: userEntryGuild.first.toString(),
            currentGuildName: currentGuildName,
          );
          print(userEntryGuild);
        }

        if (!isEntry) {
          context.go('/login_error');
        }

        print(user.uid);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('教室通知くんv2'),
        elevation: 0,
        backgroundColor: Colors.amber,
        centerTitle: false,
        automaticallyImplyLeading: false,
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
                TeacherEntryPage(),
                ChannelSettingPage(),
                RoomNotifyEntryPage(),
                GuildSettingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
