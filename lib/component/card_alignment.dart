import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/slack_alignment/slack_alignment_modal_contents.dart';

import '../controller/firestore_controller.dart';

class CardAlignment {
  static Widget setCard({
    required guildId,
    required context,
    required Map alignmentData,
  }) {
    final String alignmentId = alignmentData['id'];
    final String channelId = alignmentData['channel_id'];
    final String slackToken = alignmentData['slack_token'];

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              alignmentId,
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
                        return SlackAlignmentModalContents(
                          guildId: guildId,
                          alignmentData: alignmentData,
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
                                FirestoreController.removeSlackAlignment(
                                    guildId: guildId,
                                    slackAlignmentId: alignmentId);
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
