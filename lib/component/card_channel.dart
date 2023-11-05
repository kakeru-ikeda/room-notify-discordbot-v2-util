import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class CardChannel {
  static Widget setCard({required guildId, required channelData}) {
    final channelId = channelData['channel_id'];
    final channelName = channelData['channel_name'];
    String subject = channelData['subject'];

    TextEditingController textEditingController =
        TextEditingController(text: subject);

    Color cardColor =
        subject != '' ? const Color.fromARGB(255, 128, 255, 132) : Colors.white;

    return StatefulBuilder(builder: (context, setState) {
      return Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      channelName,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'ChannelID: $channelId',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Text('配信先: '),
                  SizedBox(
                      width: 100,
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                            hintText: '未設定',
                            contentPadding: EdgeInsets.symmetric(vertical: 16)),
                      )),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        subject = textEditingController.text;

                        FirestoreController.setChannelInfo(
                            guildId: guildId,
                            channelId: channelId,
                            field: 'subject',
                            data: subject);

                        cardColor = subject != ''
                            ? const Color.fromARGB(255, 128, 255, 132)
                            : Colors.white;

                        Fluttertoast.showToast(msg: '情報を更新しました。');
                      });
                    },
                    icon: Icon(Icons.save),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
