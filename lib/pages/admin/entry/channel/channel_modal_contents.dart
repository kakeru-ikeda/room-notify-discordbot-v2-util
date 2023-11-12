import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';

import '../../../../controller/firestore_controller.dart';

class ChannelModalContents extends StatefulWidget {
  const ChannelModalContents({
    super.key,
    required this.guildId,
    this.isEdit,
    this.channelId,
    this.subject,
    this.teacher,
  });
  final String guildId;
  final bool? isEdit;
  final String? channelId;
  final String? subject;
  final String? teacher;

  @override
  State<ChannelModalContents> createState() => _ChannelModalContentsState();
}

class _ChannelModalContentsState extends State<ChannelModalContents> {
  @override
  Widget build(BuildContext context) {
    final String guildId = widget.guildId;
    final bool isEdit = widget.isEdit ?? false;
    final String channelId = widget.channelId ?? '';
    final String subject = widget.subject ?? '';
    final String teacher = widget.teacher ?? '';

    TextEditingController subjectNameEditingController =
        TextEditingController(text: subject);

    String isSelectedChannelId = channelId;
    String isSelectedTeacher = teacher;

    return ModalContentsTemplate.setContents(
      context: context,
      contents: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              '科目チャネル ${isEdit ? '編集' : '登録'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '科目名',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width: 120,
                padding: EdgeInsets.only(right: 32),
                child: TextField(
                  controller: subjectNameEditingController,
                  decoration: InputDecoration(
                    hintText: '未設定',
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
                  '配信チャネル',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return FutureBuilder(
                      future: FirestoreController.getGuildChannelsData(
                          guildId: guildId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButton(
                              value: isSelectedChannelId,
                              items: [
                                ...snapshot.data!.docs
                                    .map((entry) => DropdownMenuItem(
                                          value: entry.data()['channel_id'],
                                          child: Text(
                                              '${entry.data()['channel_name']}'),
                                        ))
                                    .toList(),
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('未設定'),
                                )
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  isSelectedChannelId = newValue.toString();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'デフォルト教員',
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isEdit
                    ? Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (subjectNameEditingController.text == '') {
                              Fluttertoast.showToast(
                                  msg: '入力内容が空です。',
                                  webBgColor:
                                      'linear-gradient(to right, #c93d3d, #c93d3d)');
                              return;
                            }
                            FirestoreController.setChannelInfo(
                              guildId: guildId,
                              channelId: isSelectedChannelId,
                              field: 'subject',
                              data: '',
                            );
                            FirestoreController.setChannelInfo(
                              guildId: guildId,
                              channelId: isSelectedChannelId,
                              field: 'teacher',
                              data: '',
                            );
                            Navigator.pop(context);
                            Fluttertoast.showToast(msg: '情報を更新しました。');
                          },
                          icon: Icon(Icons.delete),
                          label: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '削除',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (subjectNameEditingController.text == '') {
                      Fluttertoast.showToast(
                          msg: '入力内容が空です。',
                          webBgColor:
                              'linear-gradient(to right, #c93d3d, #c93d3d)');
                      return;
                    }
                    FirestoreController.setChannelInfo(
                      guildId: guildId,
                      channelId: isSelectedChannelId,
                      field: 'subject',
                      data: subjectNameEditingController.text,
                    );
                    FirestoreController.setChannelInfo(
                      guildId: guildId,
                      channelId: isSelectedChannelId,
                      field: 'teacher',
                      data: isSelectedTeacher,
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
      ),
    );
  }
}
