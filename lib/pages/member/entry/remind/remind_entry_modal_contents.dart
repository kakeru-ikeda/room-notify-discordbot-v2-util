import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';

import '../../../../controller/firestore_controller.dart';
import '../../../../model/login_user_model.dart';

class RemindEntryModalContents extends StatefulWidget {
  const RemindEntryModalContents(
      {super.key, required this.guildId, this.remindData});
  final String guildId;
  final Map? remindData;

  @override
  State<RemindEntryModalContents> createState() =>
      _RemindEntryModalContentsState();
}

class _RemindEntryModalContentsState extends State<RemindEntryModalContents> {
  DateTime? datePicked;
  TimeOfDay? timePicked;

  bool discordEvent = false;

  Future<void> _datePicker(BuildContext context, DateTime selectedDateTime,
      TimeOfDay selectedTime) async {
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
    Map? remindData = widget.remindData;

    DateTime selectedDateTime = remindData == null
        ? DateTime.now().add(const Duration(days: 1))
        : remindData['deadline'].toDate();

    TimeOfDay selectedTime = remindData == null
        ? TimeOfDay(hour: 12, minute: 0)
        : TimeOfDay.fromDateTime(remindData['deadline'].toDate());

    TextEditingController remindMemoEditingController = TextEditingController(
        text: remindData != null ? remindData['memo'] : '');

    String isSelectedSubject = remindData != null ? remindData['subject'] : '';

    double width = MediaQuery.of(context).size.width;

    return ModalContentsTemplate.setContents(
      context: context,
      contents: StatefulBuilder(builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'リマインド 新規登録',
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
                      '配信チャネル',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: StreamBuilder(
                      stream: FirestoreController.getSubjectEnabledForChannels(
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
                                        child:
                                            Text('${entry.data()['subject']}'),
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
                  padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14),
                  child: Text(
                    '配信日時',
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
                          _datePicker(context, selectedDateTime, selectedTime)
                              .whenComplete(
                            () => setState(
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
            ),
            Divider(),
            remindData == null
                ? SwitchListTile(
                    title: const Text('Discordのイベントに登録する'),
                    value: discordEvent,
                    onChanged: (value) {
                      setState(() {
                        discordEvent = value;
                      });
                    },
                  )
                : Container(),
            remindData == null ? Divider() : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    'リマインド内容',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: width * 0.5,
                  child: TextFormField(
                    controller: remindMemoEditingController,
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
                            msg: '配信チャネルは必須入力項目です。',
                            webBgColor:
                                'linear-gradient(to right, #c93d3d, #c93d3d)');
                        return;
                      }
                      if (remindMemoEditingController.text == '') {
                        Fluttertoast.showToast(
                            msg: 'リマインド内容は必須入力項目です。',
                            webBgColor:
                                'linear-gradient(to right, #c93d3d, #c93d3d)');
                        return;
                      }

                      final entryDate = remindData == null
                          ? DateTime.now()
                          : remindData['entry_date'];

                      FirestoreController.setRemindInfo(
                        guildId: guildId,
                        remindId: entryDate.runtimeType == Timestamp
                            ? entryDate.toString()
                            : Timestamp.fromDate(entryDate).toString(),
                        data: {
                          'subject': isSelectedSubject,
                          'deadline': DateTime(
                            selectedDateTime.year,
                            selectedDateTime.month,
                            selectedDateTime.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          ),
                          'is_event': discordEvent,
                          'memo': remindMemoEditingController.text,
                          'guildId': guildId,
                          'entry_date': entryDate,
                          'entry_user_id': LoginUserModel.userId,
                          'entry_user_name': LoginUserModel.userName,
                          'entry_user_avater': LoginUserModel.userAvater,
                          'attachment': 'URL(Comming soon...)',
                          'entry_notify': false,
                          'state': true,
                        },
                        isUpdate: remindData != null,
                      );

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
        );
      }),
    );
  }
}
