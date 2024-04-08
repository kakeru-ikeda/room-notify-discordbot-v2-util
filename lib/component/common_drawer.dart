import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/controller/page_controller.dart';
import 'package:room_notify_discordbot_v2_util/controller/shared_preference_controller.dart';
import 'dart:html' as html;

import '../model/firestore_data_model.dart';
import '../model/login_user_model.dart';

/// ドロワー
class CommonDrawer extends StatefulWidget {
  const CommonDrawer({Key? key}) : super(key: key);

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  final double drawerWidth = 256.0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: drawerWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('ホーム'),
                  leading: Icon(Icons.home),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(0);
                    });
                  },
                ),
                ListTile(
                  title: Text('課題 新規登録'),
                  leading: Icon(Icons.add),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(1);
                    });
                  },
                ),
                ListTile(
                  title: Text('リマインド 新規登録'),
                  leading: Icon(Icons.add),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(2);
                    });
                  },
                ),
                ListTile(
                  title: Text('教員情報 登録'),
                  leading: Icon(Icons.person),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(3);
                    });
                  },
                ),
                ListTile(
                  title: Text('配信先チャネル 登録'),
                  leading: Icon(Icons.subject),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(4);
                    });
                  },
                ),
                ListTile(
                  title: Text('教室通知 登録'),
                  leading: Icon(Icons.note_alt),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(5);
                    });
                  },
                ),
                ListTile(
                  title: Text('Slack連携'),
                  leading: Image.asset(
                    'assets/images/slack.png',
                    height: 24,
                  ),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(6);
                    });
                  },
                ),
                ListTile(
                  title: Text('ScholarSync連携'),
                  leading: Image.asset(
                    'assets/images/scholar_sync.png',
                    height: 24,
                  ),
                  onTap: () {
                    setState(() {
                      MediaQuery.of(context).size.width <= 768
                          ? Navigator.pop(context)
                          : null;
                      IndexPageController.screen.jumpToPage(7);
                    });
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('お問い合わせ'),
            leading: Icon(Icons.mail),
            onTap: () {
              html.window
                  .open('https://forms.gle/BzSadesvTq75ENFY6', 'お問い合わせフォーム');
            },
          ),
          Container(
            child: Row(
              children: [
                Image.network(
                  "https://cdn.discordapp.com/icons/${LoginUserModel.currentGuildId}/${FirestoreDataModel.entryGuilds![LoginUserModel.currentGuildId]['guild_icon']}.png",
                  height: 50,
                  width: 50,
                ),
                Container(
                  height: 50,
                  width: drawerWidth - 50 - 40,
                  alignment: Alignment.center,
                  color: Color.fromARGB(255, 218, 224, 225),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(LoginUserModel.currentGuildName,
                      style: TextStyle(color: Colors.black)),
                ),
                Container(
                  width: 40,
                  child: IconButton(
                    onPressed: () async {
                      List<String> affiliationList =
                          await FirestoreController.getAffiliationGuild(
                              userId: LoginUserModel.userId);

                      /// ダイアログ表示
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('ギルド切り替え'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var guild in affiliationList) ...{
                                  ListTile(
                                    title: Text(FirestoreDataModel
                                        .entryGuilds![guild]!['guild_name']),
                                    onTap: () async {
                                      LoginUserModel.currentGuildId = guild;
                                      LoginUserModel.currentGuildName =
                                          FirestoreDataModel.entryGuilds![
                                              guild]!['guild_name'];

                                      await FirestoreController
                                          .setLoginUserData(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        currentGuildId: guild,
                                        currentGuildName: FirestoreDataModel
                                            .entryGuilds![guild]!['guild_name'],
                                      );

                                      html.window.location.reload();
                                    },
                                  ),
                                },
                                Divider(),
                                ListTile(
                                  title: Text('ログアウト',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () async {
                                    await FirebaseAuth.instance.signOut();
                                    final prefs =
                                        SharedPreferencesController.instance;
                                    await prefs.removeData('userId');
                                    await prefs.removeData('userName');
                                    await prefs.removeData('avatar');

                                    await prefs.removeData('currentGuildId');
                                    await prefs.removeData('currentGuildName');

                                    context.go('/login');
                                    html.window.location.reload();
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.change_circle),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
