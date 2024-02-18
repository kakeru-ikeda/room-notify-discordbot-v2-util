import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';

import '../../../controller/firestore_controller.dart';

class TeacherEntryModalContents extends StatefulWidget {
  const TeacherEntryModalContents({super.key, required this.guildId});
  final String guildId;

  @override
  State<TeacherEntryModalContents> createState() =>
      _TeacherEntryModalContentsState();
}

class _TeacherEntryModalContentsState extends State<TeacherEntryModalContents> {
  @override
  Widget build(BuildContext context) {
    String guildId = widget.guildId;

    TextEditingController teacherNameEditingController =
        TextEditingController();

    String isSelectedSubject = '';

    return ModalContentsTemplate.setContents(
      context: context,
      contents: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '教員情報 登録',
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
                    '教員名前',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: teacherNameEditingController,
                    decoration: InputDecoration(
                      hintText: '名前',
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    print(teacherNameEditingController.text.toString());
                    if (teacherNameEditingController.text == '') {
                      Fluttertoast.showToast(
                          msg: '入力内容が空です。',
                          webBgColor:
                              'linear-gradient(to right, #c93d3d, #c93d3d)');
                      return;
                    }
                    FirestoreController.setTeacherInfo(
                      guildId: guildId,
                      doc: teacherNameEditingController.text,
                      field: 'name',
                      data: teacherNameEditingController.text,
                    );
                    FirestoreController.setTeacherInfo(
                      guildId: guildId,
                      doc: teacherNameEditingController.text,
                      isUpdate: true,
                      field: 'entry_date',
                      data: DateTime.now(),
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
