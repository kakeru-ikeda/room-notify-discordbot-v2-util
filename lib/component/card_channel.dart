import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

import '../pages/admin/entry/channel/channel_modal_contents.dart';

class CardChannel {
  static Widget setCard({required guildId, required channelData}) {
    final channelId = channelData['channel_id'];
    final channelName = channelData['channel_name'];
    final subject = channelData['subject'];
    final teacher = channelData['teacher'];

    return StatefulBuilder(builder: (context, setState) {
      return InkWell(
        onTap: () async {
          showModalBottomSheet<void>(
            context: context,
            constraints: BoxConstraints.expand(),
            enableDrag: false,
            // isScrollControlled: true,
            builder: (BuildContext context) {
              return ChannelModalContents(
                guildId: guildId,
                isEdit: true,
                channelId: channelId,
                subject: subject,
                teacher: teacher,
              );
            },
          ).whenComplete(() async {});
        },
        child: Card(
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
                        subject,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '配信チャネル: $channelName',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'チャネルID: $channelId',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    teacher != ''
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'デフォルト教員: $teacher',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
