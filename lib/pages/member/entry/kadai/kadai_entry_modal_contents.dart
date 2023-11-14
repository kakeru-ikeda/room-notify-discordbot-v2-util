import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';

import '../../../../controller/firestore_controller.dart';

class KadaiModalContents extends StatefulWidget {
  const KadaiModalContents({super.key, required this.guildId});
  final String guildId;

  @override
  State<KadaiModalContents> createState() => _KadaiModalContentsState();
}

class _KadaiModalContentsState extends State<KadaiModalContents> {
  DateTime selectedDateTime = DateTime.now();
  DateTime? datePicked;
  TimeOfDay selectedTime = TimeOfDay(hour: 23, minute: 59);
  TimeOfDay? timePicked;

  bool discordEvent = false;

  Future<void> _datePicker(BuildContext context) async {
    datePicked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2099));

    timePicked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    String guildId = widget.guildId;

    TextEditingController kadaiNumEditingController = TextEditingController();
    TextEditingController kadaiTitleEditingController = TextEditingController();
    TextEditingController kadaiMemoEditingController = TextEditingController();

    String isSelectedSubject = '';
    String isSelectedTeacher = '';

    double width = MediaQuery.of(context).size.width;

    return ModalContentsTemplate.setContents(
      context: context,
      contents: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '課題通知 新規登録',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
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
                      return StreamBuilder(
                        stream:
                            FirestoreController.getSubjectEnabledForChannels(
                                guildId: guildId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton(
                                value: isSelectedSubject,
                                items: [
                                  ...snapshot.data!.docs
                                      .map(
                                        (entry) => DropdownMenuItem(
                                          value: entry.data()['subject'],
                                          child: Text(
                                              '${entry.data()['subject']}'),
                                        ),
                                      )
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
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '課題No',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: kadaiNumEditingController,
                  decoration: InputDecoration(
                    hintText: '課題No',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '課題主題',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: kadaiTitleEditingController,
                  decoration: InputDecoration(
                    hintText: '課題主題',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            ],
          ),
          Divider(),
          StatefulBuilder(builder: (context, changeValue) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14),
                  child: Text(
                    '納期',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Text(
                        '${selectedDateTime.year}/${selectedDateTime.month.toString().padLeft(2, "0")}/${selectedDateTime.day.toString().padLeft(2, "0")}  ${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}'),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          _datePicker(context).whenComplete(
                            () => changeValue(
                              () {
                                if (datePicked != null) {
                                  selectedDateTime = datePicked!;
                                }
                                if (timePicked != null) {
                                  selectedTime = timePicked!;
                                }
                              },
                            ),
                          );
                        },
                        child: Text('変更'),
                      ),
                    )
                  ],
                ),
              ],
            );
          }),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '教員',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return StreamBuilder(
                      stream: FirestoreController.getTeachers(guildId: guildId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButton(
                              value: isSelectedTeacher,
                              items: [
                                ...snapshot.data!.docs
                                    .map((entry) => DropdownMenuItem(
                                          value: entry.data()['name'],
                                          child:
                                              Text('${entry.data()['name']}'),
                                        ))
                                    .toList(),
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('未設定'),
                                )
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  isSelectedTeacher = newValue.toString();
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
          StatefulBuilder(builder: (context, setState) {
            return SwitchListTile(
              title: const Text('Discordのイベントに登録する'),
              value: discordEvent,
              onChanged: (value) {
                setState(() {
                  discordEvent = value;
                });
              },
            );
          }),
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
                width: width * 0.5,
                child: TextFormField(
                  controller: kadaiMemoEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (isSelectedSubject == '') {
                      Fluttertoast.showToast(
                          msg: '科目は必須入力項目です。',
                          webBgColor:
                              'linear-gradient(to right, #c93d3d, #c93d3d)');
                      return;
                    }
                    if (kadaiTitleEditingController.text == '') {
                      Fluttertoast.showToast(
                          msg: '課題主題は必須入力項目です。',
                          webBgColor:
                              'linear-gradient(to right, #c93d3d, #c93d3d)');
                      return;
                    }

                    final entryDate = DateTime.now();

                    FirestoreController.setKadaiInfo(
                        guildId: guildId,
                        kadaiId: Timestamp.fromDate(entryDate).toString(),
                        data: {
                          'subject': isSelectedSubject,
                          'kadai_number': kadaiNumEditingController.text,
                          'kadai_title': kadaiTitleEditingController.text,
                          'deadline': DateTime(
                            selectedDateTime.year,
                            selectedDateTime.month,
                            selectedDateTime.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          ),
                          'teacher': isSelectedTeacher,
                          'is_event': discordEvent,
                          'memo': kadaiMemoEditingController.text,
                          'guildId': guildId,
                          'entry_date': entryDate,
                          'entry_user_id': LoginUserModel.userId,
                          'entry_user_name': LoginUserModel.userName,
                          'entry_user_avater': LoginUserModel.userAvater,
                          'attachment': 'URL(Comming soon...)',
                          'entry_notify': false,
                          'state': true,
                        });

                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: '情報を更新しました。');
                  },
                  icon: Icon(Icons.save),
                  label: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '保存',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
