import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/room_notify/room_notify_modal_contents.dart';

class CardRoomNotify {
  static Widget setCard({
    required guildId,
    required roomNotifyData,
    required context,
    required week,
    required period,
    bool isHomeView = false,
  }) {
    int roomNumber = roomNotifyData['room_number'];
    String subject = roomNotifyData['subject'];
    String type = roomNotifyData['type'];
    int alartHour = roomNotifyData['alart_hour'];
    int alartMin = roomNotifyData['alart_min'];
    String zoomId = roomNotifyData['zoom_id'];
    String zoomPw = roomNotifyData['zoom_pw'];
    String zoomUrl = roomNotifyData['zoom_url'];
    String contents = roomNotifyData['contents'];
    bool state = roomNotifyData['state'];

    Color cardColor =
        state ? (type == 'room' ? Colors.green : Colors.blue) : Colors.white;

    return InkWell(
      onTap: isHomeView
          ? null
          : () {
              showModalBottomSheet<void>(
                context: context,
                constraints: BoxConstraints.expand(),
                enableDrag: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return RoomNotifyModalContents(
                    guildId: guildId,
                    roomNotifyData: roomNotifyData,
                    week: week,
                    period: period,
                  );
                },
              ).whenComplete(() async {
                Fluttertoast.showToast(msg: '情報を更新しました。');
              });
            },
      child: Card(
        color: cardColor,
        child: state
            ? SizedBox(
                height: 80,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        '🔔 ${alartHour.toString().padLeft(2, "0")}:${alartMin.toString().padLeft(2, "0")}'),
                  ],
                ))
            : SizedBox(
                height: 80,
                width: 200,
                child: Center(
                  child: Text('配信なし'),
                ),
              ),
      ),
    );
  }
}
