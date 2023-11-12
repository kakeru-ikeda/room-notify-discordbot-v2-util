import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/controller/page_controller.dart';

/// ドロワー
class CommonDrawer extends StatefulWidget {
  const CommonDrawer({Key? key}) : super(key: key);

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('管理者用ページ'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('オーナー専用ページ'),
          ),
          ListTile(
            title: Text('配信ギルド 設定'),
            leading: Icon(Icons.settings),
            onTap: () {
              setState(() {
                MediaQuery.of(context).size.width <= 768
                    ? Navigator.pop(context)
                    : null;
                IndexPageController.screen.jumpToPage(6);
              });
            },
          ),
        ],
      ),
    );
  }
}
