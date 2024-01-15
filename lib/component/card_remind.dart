import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/remind/remind_entry_modal_contents.dart';
import '../controller/firestore_controller.dart';
import '../model/login_user_model.dart';

class CardRemind {
  static Widget setCard({
    required guildId,
    required remindData,
    required context,
    required deviceWidth,
    bool isHomeView = false,
  }) {
    final String subject = remindData['subject'];
    final String remindMemo = remindData['memo'].replaceAll('\n', ' ');
    final DateTime deadline = remindData['deadline'].toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final Timestamp entryDate = remindData['entry_date'];

    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject),
                  ],
                ),
                Container(
                  width: deviceWidth * 0.6,
                  child: Text(remindMemo,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis)),
                ),
              ],
            ),
            Row(
              children: [
                Text(formatter.format(deadline)),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: isHomeView
                      ? null
                      : IconButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              constraints: BoxConstraints.expand(),
                              enableDrag: false,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return RemindEntryModalContents(
                                  guildId: LoginUserModel.currentGuildId,
                                  remindData: remindData,
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black,
                          )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: isHomeView
                      ? null
                      : IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('リマインドを削除します'),
                                    content: Text('本当によろしいですか？'),
                                    actions: [
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          FirestoreController.removeRemind(
                                              guildId: guildId,
                                              remindId: entryDate.toString());
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
                          )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
