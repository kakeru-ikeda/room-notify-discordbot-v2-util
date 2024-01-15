import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/card_teacher.dart';
import 'package:room_notify_discordbot_v2_util/component/page_template.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/admin/entry/teacher/teacher_entry_modal_contents.dart';

import '../../../../controller/firestore_controller.dart';

class TeacherEntryPage extends StatefulWidget {
  const TeacherEntryPage({super.key});

  @override
  State<TeacherEntryPage> createState() => _TeacherEntryPageState();
}

class _TeacherEntryPageState extends State<TeacherEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTemplate.setPageTitle(
              title: '教員情報 登録',
              caption: '課題通知に利用される教員の情報を登録します。Adminユーザーのみ編集可能です',
            ),
            PageTemplate.setGuildInfoTitle(
                guildId: LoginUserModel.currentGuildId),
            ElevatedButton.icon(
              onPressed: () async {
                showModalBottomSheet<void>(
                  context: context,
                  constraints: BoxConstraints.expand(),
                  enableDrag: false,
                  // isScrollControlled: true,
                  builder: (BuildContext context) {
                    return TeacherEntryModalContents(
                      guildId: LoginUserModel.currentGuildId,
                    );
                  },
                ).whenComplete(() async {});
              },
              icon: Icon(Icons.add),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '教員追加',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            StreamBuilder(
              stream: FirestoreController.getTeachers(
                  guildId: LoginUserModel.currentGuildId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data!.docs);
                  if (snapshot.data!.docs.isNotEmpty) {
                    return SizedBox(
                      height: 500,
                      child: SingleChildScrollView(
                        child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data!.docs
                              .map((user) => CardTeacher.setCard(
                                    guildId: LoginUserModel.currentGuildId,
                                    context: context,
                                    teacherData: user.data(),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  } else {
                    return Text('教員が登録されていません');
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          ],
        ));
  }
}
