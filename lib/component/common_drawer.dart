import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/style/material_color_name.dart';
import 'package:room_notify_discordbot_v2_util/controller/page_controller.dart';

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
                  title: Text('科目チャネル 登録'),
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
              ],
            ),
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
                  width: drawerWidth - 50 - 20,
                  alignment: Alignment.center,
                  color: Color.fromARGB(255, 218, 224, 225),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(LoginUserModel.currentGuildName,
                      style: TextStyle(color: Colors.black)),
                ),
                Container(
                    width: 20,
                    child: IconButton(
                        onPressed: () {}, icon: Icon(Icons.change_circle))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
