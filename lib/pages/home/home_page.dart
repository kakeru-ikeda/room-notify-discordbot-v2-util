import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_kadai.dart';
import 'package:room_notify_discordbot_v2_util/component/card_remind.dart';
import 'package:room_notify_discordbot_v2_util/component/card_room_notify.dart';
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
    6: 'saturday',
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
    DateTime remindDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        now = now.subtract(Duration(days: 1));
                      });
                    },
                    child: Text(
                      '<',
                      style: TextStyle(fontSize: 30),
                    )),
                Text(
                  "${now.month}" +
                      "月" +
                      "${now.day}" +
                      "日" +
                      " ${WEEKS_JP[now.weekday]}",
                  style: TextStyle(fontSize: 40),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      now = now.add(Duration(days: 1));
                    });
                  },
                  child: Text(
                    '>',
                    style: TextStyle(fontSize: 30),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 2000,
              height: 750,
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Container(
                    alignment: Alignment(0.0, 0.0),
                    child: (now.weekday != 6)
                        ? (now.weekday != 7)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamBuilder(
                                      stream: FirestoreController.getRoomNotify(
                                          guildId:
                                              LoginUserModel.currentGuildId,
                                          week: WEEK[now.weekday]),
                                      builder: (content, snapshot) {
                                        if (snapshot.hasData) {
                                          return Column(
                                            children: [
                                              for (int j = 1;
                                                  j <=
                                                      snapshot.data!
                                                          .data()!
                                                          .length;
                                                  j++) ...{
                                                CardRoomNotify.setCard(
                                                    context: context,
                                                    guildId: LoginUserModel
                                                        .currentGuildId,
                                                    roomNotifyData: snapshot
                                                        .data!
                                                        .data()!['$j'],
                                                    week: WEEK[now.weekday],
                                                    period: j,
                                                    isHomeView: true),
                                              }
                                            ],
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        StreamBuilder(
                                          stream:
                                              FirestoreController.getReminds(
                                            guildId:
                                                LoginUserModel.currentGuildId,
                                            isEnabled: true,
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              var todayRemind = snapshot
                                                  .data!.docs
                                                  .where((user) {
                                                DateTime deadlineDate = user
                                                    .data()['deadline']
                                                    .toDate();
                                                return deadlineDate.year ==
                                                        remindDate.year &&
                                                    deadlineDate.month ==
                                                        remindDate.month &&
                                                    deadlineDate.day ==
                                                        remindDate.day;
                                              });
                                              return SizedBox(
                                                height: 300,
                                                width: 800,
                                                child: SingleChildScrollView(
                                                    child: (todayRemind.isEmpty)
                                                        ? Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              '今日のリマインド内容はありません',
                                                              style: TextStyle(
                                                                  fontSize: 30),
                                                            ),
                                                          )
                                                        : ListView(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            children: todayRemind
                                                                .map((user) => CardRemind.setCard(
                                                                    guildId:
                                                                        LoginUserModel
                                                                            .currentGuildId,
                                                                    context:
                                                                        context,
                                                                    remindData: user
                                                                        .data(),
                                                                    isHomeView:
                                                                        true))
                                                                .toList())),
                                              );
                                            } else {
                                              return const CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                        StreamBuilder(
                                          stream: FirestoreController.getKadai(
                                              guildId:
                                                  LoginUserModel.currentGuildId,
                                              isEnabled: true),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              var todayKadai = snapshot
                                                  .data!.docs
                                                  .where((user) {
                                                DateTime deadlineDate = user
                                                    .data()['deadline']
                                                    .toDate();
                                                return deadlineDate.year ==
                                                        remindDate.year &&
                                                    deadlineDate.month ==
                                                        remindDate.month &&
                                                    deadlineDate.day ==
                                                        remindDate.day;
                                              });
                                              return SizedBox(
                                                height: 300,
                                                width: 800,
                                                child: SingleChildScrollView(
                                                  child: (todayKadai.isEmpty)
                                                      ? Center(
                                                          child: Text(
                                                            '今日が期限の課題はありません',
                                                            style: TextStyle(
                                                                fontSize: 30),
                                                          ),
                                                        )
                                                      : ListView(
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          children: todayKadai
                                                              .map((user) =>
                                                                  CardKadai
                                                                      .setCard(
                                                                    guildId:
                                                                        LoginUserModel
                                                                            .currentGuildId,
                                                                    context:
                                                                        context,
                                                                    kadaiData: user
                                                                        .data(),
                                                                    isHomeView:
                                                                        true,
                                                                  ))
                                                              .toList()),
                                                ),
                                              );
                                            } else {
                                              return const CircularProgressIndicator();
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '土日は基本休みです',
                                style: TextStyle(fontSize: 40),
                              )
                        : Text(
                            '土日は基本休みです',
                            style: TextStyle(fontSize: 40),
                          ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
