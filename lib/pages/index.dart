import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:room_notify_discordbot_v2_util/component/style/material_color_name.dart';
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
import '../controller/shared_preference_controller.dart';
import '../model/firestore_data_model.dart';
import 'home/home_page.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  SharedPreferencesController prfs = SharedPreferencesController.instance;
  String? userId;
  String? userName;
  String? userAvatar;

  Future<void> getPrfsData() async {
    userId = await prfs.getData('userId');
    userName = await prfs.getData('userName');
    userAvatar = await prfs.getData('avatar');
    userAvatar = 'https://cdn.discordapp.com/avatars/$userId/$userAvatar';

    LoginUserModel.userId = userId!;
    LoginUserModel.userName = userName!;
    LoginUserModel.userAvatar = userAvatar!;

    await prfs.removeData('isAdministrator');
  }

  Future<PackageInfo> getVersionData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<void> checkLogin(User? user) async {
    List userEntryGuild = [];
    bool isEntry = false;

    await FirestoreController.getEntryGuilds();
    if (user != null) {
      print('user: ${user.uid}');
      if (userId.isNull || userId!.isEmpty) {
        print('👑 User ID is Empty');
        context.go('/login_error');
      }

      for (String guildId in FirestoreDataModel.entryGuilds!.keys) {
        final userDocData = await FirestoreController.getGuildEntryUser(
          guildId: guildId,
          userId: userId!,
        );

        if (userDocData.data().isNull) {
          continue;
        }

        if (userDocData.exists && userDocData.data()!['user_id'] == userId!) {
          isEntry = true;
          userEntryGuild.add(guildId);
          userEntryGuild.sort(((a, b) => a.compareTo(b)));
        }

        if (guildId == FirestoreDataModel.entryGuilds!.keys.last) {
          continue;
        }

        final guildDocData = await FirestoreController.getGuildData();

        final currentGuildName =
            guildDocData.data()![userEntryGuild.first.toString()]['guild_name'];

        await FirestoreController.setLoginUserData(
          uid: user.uid,
          currentGuildId: userEntryGuild.first.toString(),
          currentGuildName: currentGuildName,
        );

        getPrfsData();
        setState(() {});
      }

      if (!isEntry) {
        Fluttertoast.showToast(msg: 'Login Error');
        context.go('/user_undefind');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) async => checkLogin(user));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPrfsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Row(
                  children: [
                    Text('教室通知くん',
                        style: TextStyle(
                            fontSize: 20,
                            color: MaterialColorName.mcgpalette0[50])),
                    const SizedBox(
                      width: 16,
                    ),
                    FutureBuilder(
                      future: getVersionData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          PackageInfo packageInfo =
                              snapshot.data as PackageInfo;
                          return Text(
                            'v${packageInfo.version} (${packageInfo.buildNumber})',
                            style: TextStyle(
                                fontSize: 12,
                                color: MaterialColorName.mcgpalette0[100]),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                elevation: 0,
                backgroundColor: MaterialColorName.mcgpalette0,
                centerTitle: false,
                automaticallyImplyLeading:
                    MediaQuery.of(context).size.width <= 768,
                actions: [
                  Row(
                    children: [
                      Image.network('$userAvatar'),
                      Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$userName'),
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
                    child: FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 2)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return PageView(
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
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
