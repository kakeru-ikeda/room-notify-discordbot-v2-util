import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_kadai.dart';
import 'package:room_notify_discordbot_v2_util/component/card_remind.dart';
import 'package:room_notify_discordbot_v2_util/component/card_room_notify.dart';
import 'package:room_notify_discordbot_v2_util/component/card_room_notify_home.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();

  final WEEK = {
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saurday',
    7: 'sunday'
  };
  final WEEKS_JP = {
    1: '月曜日',
    2: '火曜日',
    3: '水曜日',
    4: '木曜日',
    5: '金曜日',
    6: '土曜日',
    7: '日曜日'
  };

  @override
  Widget build(BuildContext context) {
    DateTime remindLastDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    DateTime remindStartDate = DateTime(
      now.year,
      now.month,
      now.add(Duration(days: 1)).day,
    );

    Timestamp remindLastTimestamp = Timestamp.fromDate(remindLastDate);
    Timestamp remindStartTimestamp = Timestamp.fromDate(remindStartDate);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      now = now.subtract(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.chevron_left),
                  label: Text("前の日へ"),
                ),
                Text(
                  "${now.month}" +
                      "月" +
                      "${now.day}" +
                      "日" +
                      " ${WEEKS_JP[now.weekday]}",
                  style: TextStyle(fontSize: 40),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      now = now.add(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.chevron_right),
                  label: Text("次の日へ"),
                )
              ],
            ),
            SizedBox(
              width: 2000,
              height: 750,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '今日の教室通知',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        (now.weekday == 6 || now.weekday == 7)
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '今日のリマインド内容はありません',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                              )
                            : StreamBuilder(
                                stream: FirestoreController.getRoomNotify(
                                    guildId: LoginUserModel.currentGuildId,
                                    week: WEEK[now.weekday]),
                                builder: (content, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        for (int j = 1;
                                            j <= snapshot.data!.data()!.length;
                                            j++) ...{
                                          CardRoomNotifyHome.setCard(
                                            context: context,
                                            guildId:
                                                LoginUserModel.currentGuildId,
                                            roomNotifyData:
                                                snapshot.data!.data()!['$j'],
                                            week: WEEK[now.weekday],
                                            period: j,
                                          ),
                                        }
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '今日のリマインド',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        StreamBuilder(
                          stream: FirestoreController.getRemindsHome(
                            guildId: LoginUserModel.currentGuildId,
                            isEnabled: true,
                            remindStartDate: remindStartTimestamp,
                            remindLastDate: remindLastTimestamp,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print('💩${snapshot.data}');
                              return SingleChildScrollView(
                                  child: (snapshot.data!.docs.isEmpty)
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              '今日のリマインド内容はありません',
                                              style: TextStyle(fontSize: 25),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: snapshot.data!.docs
                                              .map((user) => CardRemind.setCard(
                                                  guildId: LoginUserModel
                                                      .currentGuildId,
                                                  context: context,
                                                  remindData: user.data(),
                                                  isHomeView: true))
                                              .toList()));
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '今日の課題通知',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        StreamBuilder(
                          stream: FirestoreController.getKadaiHome(
                              guildId: LoginUserModel.currentGuildId,
                              isEnabled: true,
                              remindStartDate: remindStartDate,
                              remindLastDate: remindLastDate),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                child: (snapshot.data!.docs.isEmpty)
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '今日が期限の課題はありません',
                                            style: TextStyle(fontSize: 25),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: snapshot.data!.docs
                                            .map((user) => CardKadai.setCard(
                                                  guildId: LoginUserModel
                                                      .currentGuildId,
                                                  context: context,
                                                  kadaiData: user.data(),
                                                  isHomeView: true,
                                                ))
                                            .toList()),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
