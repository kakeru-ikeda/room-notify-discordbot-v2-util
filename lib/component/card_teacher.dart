import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class CardTeacher {
  static Widget setCard({
    required guildId,
    required context,
    required Map teacherData,
  }) {
    String teacherName = teacherData['name'];

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              teacherName,
              style: TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('教員情報を削除します'),
                      content: Text('本当によろしいですか？'),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            FirestoreController.removeTeacher(
                                guildId: guildId, teacherName: teacherName);
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
          )
        ],
      ),
    );
  }
}
