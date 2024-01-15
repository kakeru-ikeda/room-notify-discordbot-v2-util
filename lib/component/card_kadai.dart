import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/member/entry/kadai/kadai_entry_modal_contents.dart';

class CardKadai {
  static Widget setCard(
      {required guildId,
      required kadaiData,
      required context,
      required deviceWidth,
      bool isHomeView = false}) {
    final String subject = kadaiData['subject'];
    final String kadaiNumber = kadaiData['kadai_number'];
    final String kadaiTitle = kadaiData['kadai_title'];
    final DateTime deadline = kadaiData['deadline'].toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final Timestamp entryDate = kadaiData['entry_date'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('課題No.$kadaiNumber'),
                    )
                  ],
                ),
                Text(kadaiTitle,
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('${formatter.format(deadline)} 迄'),
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
                                return KadaiModalContents(
                                  guildId: LoginUserModel.currentGuildId,
                                  kadaiData: kadaiData,
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
                                    title: Text('課題を削除します'),
                                    content: Text('本当によろしいですか？'),
                                    actions: [
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          FirestoreController.removeKadai(
                                              guildId: guildId,
                                              kadaiId: entryDate.toString());
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
