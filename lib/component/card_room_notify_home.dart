import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/pages/entry/room_notify/room_notify_modal_contents.dart';

class CardRoomNotifyHome {
  static Widget setCard({
    required guildId,
    required roomNotifyData,
    required context,
    required week,
    required period,
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

    final Map<int, String> TIME_SCHEDULE = {
      1: '9:30',
      2: '11:15',
      3: '13:00',
      4: '14:40',
      5: '16:20',
      6: '18:00'
    };

    if (state) {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${period}" + "限"),
                    Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(TIME_SCHEDULE[period]!))
                  ],
                ),
                (type == "room")
                    ? Text('$subject ' '$roomNumber教室',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold))
                    : Text(
                        '$subject ' 'ZOOM',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      )
              ],
            ),
          ],
        ),
      ));
    } else {
      return Container();
    }
  }
}
