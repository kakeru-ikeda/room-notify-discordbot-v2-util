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
        if (LoginUserModel.userId.isEmpty) {
          context.go('/login_error');
        }

        for (String guildId in FirestoreDataModel.entryGuilds!.keys) {
          final userDocData = await FirestoreController.getGuildEntryUser(
            guildId: guildId,
            userId: LoginUserModel.userId,
          );

          if (userDocData.data().isNull) {
            continue;
          }

          if (userDocData.exists &&
              userDocData.data()!['user_id'] == LoginUserModel.userId) {
            isEntry = true;
            userEntryGuild.add(guildId);
            userEntryGuild.sort(((a, b) => a.compareTo(b)));
          }

          final guildDocData = await FirestoreController.getGuildData();

          final currentGuildName = guildDocData
              .data()![userEntryGuild.first.toString()]['guild_name'];

          await FirestoreController.setLoginUserData(
            uid: user.uid,
            currentGuildId: userEntryGuild.first.toString(),
            currentGuildName: currentGuildName,
          );
        }

        if (!isEntry) {
          Fluttertoast.showToast(msg: 'Login Error');
          context.go('/user_undefind');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('教室通知くんv2'),
        elevation: 0,
        backgroundColor: Colors.amber,
        centerTitle: false,
        automaticallyImplyLeading: MediaQuery.of(context).size.width <= 768,
        actions: [
          Row(
            children: [
              Image.network(LoginUserModel.userAvater),
              Container(
                height: double.infinity,
                alignment: Alignment.center,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(LoginUserModel.userName),
              )
            ],
          )
        ],
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
