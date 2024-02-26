import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';

import '../../../controller/firestore_controller.dart';

class SlackAlignmentModalContents extends StatefulWidget {
  const SlackAlignmentModalContents(
      {super.key, required this.guildId, this.alignmentData});
  final String guildId;
  final Map? alignmentData;

  @override
  State<SlackAlignmentModalContents> createState() =>
      _SlackAlignmentModalContentsState();
}

class _SlackAlignmentModalContentsState
    extends State<SlackAlignmentModalContents> {
  late String guildId;
  late TextEditingController slackAlignmentIdController;
  late TextEditingController slackTokenEditingController;
  late String alignmentUrl;
  late String isSelectedChannelId;

  @override
  void initState() {
    super.initState();
    guildId = widget.guildId;
    slackAlignmentIdController = TextEditingController(
        text: widget.alignmentData != null ? widget.alignmentData!['id'] : '');
    slackTokenEditingController = TextEditingController(
        text: widget.alignmentData != null
            ? widget.alignmentData!['slack_token']
            : '');
    alignmentUrl =
        'https://us-central1-room-notify-v2.cloudfunctions.net/alignment/slack/$guildId/${slackAlignmentIdController.text}';
    isSelectedChannelId =
        widget.alignmentData != null ? widget.alignmentData!['channel_id'] : '';
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentsTemplate.setContents(
        context: context,
        contents: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slack連携設定',
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
                      '連携用ID',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: slackAlignmentIdController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: InputDecoration(
                        hintText: 'ID',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          alignmentUrl =
                              'https://us-central1-room-notify-v2.cloudfunctions.net/alignment/slack/$guildId/${slackAlignmentIdController.text}';
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Slack App認証用トークン',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: slackTokenEditingController,
                      decoration: InputDecoration(
                        hintText: 'トークン',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                ],
              ),
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
                  StatefulBuilder(builder: (context, setState) {
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
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '連携用URL: $alignmentUrl',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: alignmentUrl));
                      Fluttertoast.showToast(msg: 'コピーしました');
                    },
                    child: Text('コピー'),
                  ),
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
                      if (slackAlignmentIdController.text == '' ||
                          slackTokenEditingController.text == '' ||
                          isSelectedChannelId == '') {
                        Fluttertoast.showToast(
                            msg: '未入力の項目があります。',
                            webBgColor:
                                'linear-gradient(to right, #c93d3d, #c93d3d)');
                        return;
                      }
                      FirestoreController.setSlackAlignmentData(
                        guildId: guildId,
                        slackAlignmentId: slackAlignmentIdController.text,
                        slackToken: slackTokenEditingController.text,
                        channelId: isSelectedChannelId,
                      );
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: '情報を更新しました。');
                    },
                    icon: Icon(Icons.save),
                    label: Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
