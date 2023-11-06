import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_room_notify.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';

import '../../../../component/page_template.dart';

class RoomNotifyEntryPage extends StatefulWidget {
  const RoomNotifyEntryPage({super.key});

  @override
  State<RoomNotifyEntryPage> createState() => _RoomNotifyEntryPageState();
}

class _RoomNotifyEntryPageState extends State<RoomNotifyEntryPage> {
  @override
  Widget build(BuildContext context) {
    final WEEK = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
    };
    final WEEKS_JP = {
      1: '月曜日',
      2: '火曜日',
      3: '水曜日',
      4: '木曜日',
      5: '金曜日',
    };

    String isSelectedChannel = '';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTemplate.setPageTitle(
              title: '教室通知 登録・編集',
              caption:
                  '毎日の教室通知の配信を登録します。配信内容の変更や長期休暇時の配信停止の設定もこちらから。Adminユーザーのみ編集可能です。'),
          PageTemplate.setGuildInfoTitle(
              guildId: LoginUserModel.currentGuildId),
          StatefulBuilder(builder: (context, changeValue) {
            return FutureBuilder(
              future: FirestoreController.getGuildChannelsData(
                  guildId: LoginUserModel.currentGuildId),
              builder: (context, snapshot) {
                print(snapshot.data);
                if (snapshot.hasData) {
                  return DropdownButton(
                      value: isSelectedChannel,
                      items: [
                        ...snapshot.data!.docs
                            .map((entry) => DropdownMenuItem(
                                  value: entry.data()['channel_name'],
                                  child:
                                      Text('${entry.data()['channel_name']}'),
                                ))
                            .toList(),
                        const DropdownMenuItem(
                          value: '',
                          child: Text('未設定'),
                        )
                      ],
                      onChanged: (newValue) {
                        changeValue(() {
                          isSelectedChannel = newValue.toString();
                        });
                      });
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          }),
          Row(
            children: [
              Column(
                children: [
                  for (int i = 1; i <= 6; i++) ...{
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: Center(child: Text('$i限')),
                      ),
                    ),
                  }
                ],
              ),
              Row(
                children: [
                  for (int i = 1; i <= WEEK.length; i++) ...{
                    SizedBox(
                      height: 600,
                      width: 200,
                      child: StreamBuilder(
                        stream: FirestoreController.getRoomNotify(
                            guildId: LoginUserModel.currentGuildId,
                            week: WEEK[i]),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(WEEKS_JP[i]!),
                                ),
                                for (int j = 1;
                                    j <= snapshot.data!.data()!.length;
                                    j++) ...{
                                  CardRoomNotify.setCard(
                                      context: context,
                                      guildId: LoginUserModel.currentGuildId,
                                      roomNotifyData:
                                          snapshot.data!.data()!['$j'],
                                      week: WEEK[i],
                                      period: j),
                                }
                              ],
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    )
                  }
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
