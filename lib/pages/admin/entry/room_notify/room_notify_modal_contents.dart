import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';

import '../../../../controller/firestore_controller.dart';

class RoomNotifyModalContents extends StatefulWidget {
  const RoomNotifyModalContents({
    super.key,
    required this.guildId,
    required this.roomNotifyData,
    required this.week,
    required this.period,
  });
  final String guildId;
  final roomNotifyData;
  final String week;
  final int period;

  @override
  State<RoomNotifyModalContents> createState() =>
      _RoomNotifyModalContentsState();
}

class _RoomNotifyModalContentsState extends State<RoomNotifyModalContents> {
  @override
  Widget build(BuildContext context) {
    int roomNumber = widget.roomNotifyData['room_number'];
    String subject = widget.roomNotifyData['subject'];
    String type = widget.roomNotifyData['type'];
    int alartHour = widget.roomNotifyData['alart_hour'];
    int alartMin = widget.roomNotifyData['alart_min'];
    String zoomId = widget.roomNotifyData['zoom_id'];
    String zoomPw = widget.roomNotifyData['zoom_pw'];
    String zoomUrl = widget.roomNotifyData['zoom_url'];
    String contents = widget.roomNotifyData['contents'];
    bool state = widget.roomNotifyData['state'];

    bool typeBool = type == 'zoom' ? true : false;

    final String week = widget.week;
    final int period = widget.period;

    final String guildId = widget.guildId;

    double width = MediaQuery.of(context).size.width;

    final Map<String, String> WEEKS_JP = {
      'monday': '月曜日',
      'tuesday': '火曜日',
      'wednesday': '水曜日',
      'thursday': '木曜日',
      'friday': '金曜日'
    };

    final Map<String, int> WEEKS_NUM = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5
    };

    final Map<int, String> TIME_SCHEDULE = {
      1: '9:30',
      2: '11:15',
      3: '13:00',
      4: '14:40',
      5: '16:20',
      6: '18:00'
    };

    String isSelectedSubject = subject;

    TimeOfDay selectedTime = TimeOfDay(hour: alartHour, minute: alartMin);
    TimeOfDay? picked;

    TextEditingController roomNumberEditingController =
        TextEditingController(text: roomNumber.toString());
    TextEditingController zoomIdEditingController =
        TextEditingController(text: zoomId);
    TextEditingController zoomPwEditingController =
        TextEditingController(text: zoomPw);
    TextEditingController zoomUrlEditingController =
        TextEditingController(text: zoomUrl);
    TextEditingController contentsEditingController =
        TextEditingController(text: contents);

    Future<void> _selectTime(BuildContext context) async {
      picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
    }

    return ModalContentsTemplate.setContents(
        context: context,
        contents: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${WEEKS_JP[week]} $period限 (${TIME_SCHEDULE[period]}〜)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('◯ 配信設定'),
            ),
            StatefulBuilder(
              builder: (context, changeValue) {
                return SwitchListTile(
                  title: const Text('このコマで教室通知の配信を行う'),
                  value: state,
                  onChanged: (value) {
                    changeValue(() {
                      state = value;
                    });
                    // FirestoreController.setRoomNotifyInfo(guildId: guildId, week: week, field: field, data: data)
                  },
                  secondary: const Icon(Icons.send),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('◯ 配信内容登録'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '科目',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return FutureBuilder(
                        future:
                            FirestoreController.getSubjectEnabledForChannels(
                                guildId: guildId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton(
                                value: isSelectedSubject,
                                items: [
                                  ...snapshot.data!.docs
                                      .map((entry) => DropdownMenuItem(
                                            value: entry.data()['subject'],
                                            child: Text(
                                                '${entry.data()['subject']}'),
                                          ))
                                      .toList(),
                                  const DropdownMenuItem(
                                    value: '',
                                    child: Text('未設定'),
                                  )
                                ],
                                onChanged: (newValue) {
                                  setState(() {
                                    isSelectedSubject = newValue.toString();
                                  });
                                });
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            Divider(),
            StatefulBuilder(
              builder: (context, changeValue) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '配信時刻',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 32, top: 8, bottom: 8),
                          child: ElevatedButton(
                              onPressed: () {
                                _selectTime(context)
                                    .whenComplete(() => changeValue(
                                          () {
                                            if (picked != null) {
                                              selectedTime = picked!;
                                            }
                                          },
                                        ));
                              },
                              child: Text('変更')),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
            Divider(),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('オンライン授業'),
                      value: typeBool,
                      onChanged: (value) {
                        setState(() {
                          typeBool = value;
                        });
                        // FirestoreController.setRoomNotifyInfo(guildId: guildId, week: week, field: field, data: data)
                      },
                    ),
                    Divider(),
                    Column(
                      children: typeBool
                          ? [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      'Zoom ID',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: zoomIdEditingController,
                                      decoration: InputDecoration(
                                        hintText: '未設定',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      'Zoom パスワード',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: zoomPwEditingController,
                                      decoration: InputDecoration(
                                        hintText: '未設定',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      'Zoom URL',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: TextField(
                                      controller: zoomUrlEditingController,
                                      decoration: InputDecoration(
                                        hintText: '未設定',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ]
                          : [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      '教室番号',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: roomNumberEditingController,
                                      decoration: InputDecoration(
                                        hintText: '未設定',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'メモ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          width: width / 2,
                          child: TextField(
                            controller: contentsEditingController,
                            decoration: InputDecoration(
                              hintText: '未設定',
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                );
              },
            )
          ],
        ),
        willPopFunction: () async {
          String text =
              '【${typeBool ? "Zoom通知" : "教室通知"}】${WEEKS_JP[week]} ${TIME_SCHEDULE[period]}〜 $isSelectedSubject ${typeBool ? "¥nID: ${zoomIdEditingController.text}¥nPW: ${zoomPwEditingController.text}¥n${zoomUrlEditingController.text}" : "${roomNumberEditingController.text}教室"} ${contentsEditingController.text != "" ? "¥n${contentsEditingController.text}" : ""}';
          FirestoreController.setRoomNotifyInfo(
              guildId: guildId,
              week: week,
              field: period.toString(),
              data: {
                'room_number': int.parse(roomNumberEditingController.text),
                'subject': isSelectedSubject,
                'type': typeBool ? 'zoom' : 'room',
                'alart_week': WEEKS_NUM[week],
                'alart_hour': selectedTime.hour,
                'alart_min': selectedTime.minute,
                'zoom_id': zoomIdEditingController.text,
                'zoom_pw': zoomPwEditingController.text,
                'zoom_url': zoomUrlEditingController.text,
                'contents': contentsEditingController.text,
                'state': state,
                'text': text,
              });
        });
  }
}
