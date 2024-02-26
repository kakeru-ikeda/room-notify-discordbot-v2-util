import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';

import '../../../controller/firestore_controller.dart';

class SlackExternalModalContents extends StatefulWidget {
  const SlackExternalModalContents(
      {super.key, required this.guildId, this.externalData});
  final String guildId;
  final Map? externalData;

  @override
  State<SlackExternalModalContents> createState() =>
      _SlackExternalModalContentsState();
}

class _SlackExternalModalContentsState
    extends State<SlackExternalModalContents> {
  late String guildId;
  late TextEditingController slackexternalIdController;
  late TextEditingController slackTokenEditingController;
  late String externalUrl;
  late String selectedChannelId;
  late String selectedChannelName;

  @override
  void initState() {
    super.initState();
    guildId = widget.guildId;
    slackexternalIdController = TextEditingController(
        text: widget.externalData != null ? widget.externalData!['id'] : '');
    slackTokenEditingController = TextEditingController(
        text: widget.externalData != null
            ? widget.externalData!['slack_token']
            : '');
    externalUrl =
        'https://us-central1-room-notify-v2.cloudfunctions.net/external/slack/$guildId/${slackexternalIdController.text}';
    selectedChannelId =
        widget.externalData != null ? widget.externalData!['channel_id'] : '';
    selectedChannelName =
        widget.externalData != null ? widget.externalData!['subject'] : '未設定';
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
                      controller: slackexternalIdController,
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
                          externalUrl =
                              'https://us-central1-room-notify-v2.cloudfunctions.net/external/slack/$guildId/${slackexternalIdController.text}';
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
                              value: selectedChannelId,
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
                                  selectedChannelId = newValue.toString();
                                  selectedChannelName = snapshot.data!.docs
                                      .firstWhere((element) =>
                                          element.data()['channel_id'] ==
                                          selectedChannelId)['channel_name'];
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
                      '連携用URL: $externalUrl',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: externalUrl));
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
                      if (slackexternalIdController.text == '' ||
                          slackTokenEditingController.text == '' ||
                          selectedChannelId == '') {
                        Fluttertoast.showToast(
                            msg: '未入力の項目があります。',
                            webBgColor:
                                'linear-gradient(to right, #c93d3d, #c93d3d)');
                        return;
                      }
                      FirestoreController.setSlackExternalData(
                        guildId: guildId,
                        slackexternalId: slackexternalIdController.text,
                        slackToken: slackTokenEditingController.text,
                        channelId: selectedChannelId,
                        channelName: selectedChannelName,
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
