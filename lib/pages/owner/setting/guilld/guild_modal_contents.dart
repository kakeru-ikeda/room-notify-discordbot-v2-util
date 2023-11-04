import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/user_list.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class GuildModalContents extends StatefulWidget {
  const GuildModalContents({
    super.key,
    required BuildContext context,
    required this.guildId,
    required this.guildName,
    required this.guildIcon,
    required this.guildState,
    this.edit = false,
  });
  final String guildId;
  final String guildName;
  final String guildIcon;
  final bool guildState;
  final bool edit;

  @override
  State<GuildModalContents> createState() => _GuildModalContentsState();
}

class _GuildModalContentsState extends State<GuildModalContents> {
  late String guildId;
  late String guildName;
  late String guildIcon;
  late bool guildState;
  late bool edit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    guildId = widget.guildId;
    guildName = widget.guildName;
    guildIcon = widget.guildIcon;
    guildState = widget.guildState;
    edit = widget.edit;
  }

  static Future<bool> _modalWillPop() async {
    print('👑 Willpop');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _modalWillPop(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close,
                    size: 24,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guildName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'GuildID: $guildId',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text('◯ 配信設定'),
                ),
                StatefulBuilder(
                  builder: (context, changeValue) {
                    return SwitchListTile(
                      title: const Text('このギルドへの配信を行う'),
                      value: guildState,
                      onChanged: (value) {
                        changeValue(() {
                          guildState = value;
                        });
                        FirestoreController.setGuildInfo(
                            guildId: guildId, field: 'state', data: value);
                      },
                      secondary: const Icon(Icons.send),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text('◯ ユーザーの一覧とロール'),
                ),
                UserList(guildId: guildId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
