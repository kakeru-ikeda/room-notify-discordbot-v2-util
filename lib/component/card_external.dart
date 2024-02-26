import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/slack_external/slack_external_modal_contents.dart';

import '../controller/firestore_controller.dart';

class CardExternal {
  static Widget setCard({
    required guildId,
    required context,
    required Map externalData,
  }) {
    final String externalId = externalData['id'];

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              externalId,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      constraints: BoxConstraints.expand(),
                      enableDrag: false,
                      builder: (context) {
                        return SlackExternalModalContents(
                          guildId: guildId,
                          externalData: externalData,
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                  )),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Slack連携情報を削除します'),
                          content: Text('本当によろしいですか？'),
                          actions: [
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                FirestoreController.removeSlackExternal(
                                    guildId: guildId,
                                    slackexternalId: externalId);
                                Fluttertoast.showToast(msg: '削除が完了しました');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
