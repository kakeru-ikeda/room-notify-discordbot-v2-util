import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents_template.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';

class ChannelModalContents extends StatefulWidget {
  const ChannelModalContents({super.key, required this.guildId});
  final String guildId;

  @override
  State<ChannelModalContents> createState() => _ChannelModalContentsState();
}

class _ChannelModalContentsState extends State<ChannelModalContents> {
  @override
  Widget build(BuildContext context) {
    final String guildId = widget.guildId;
    return ModalContentsTemplate.setContents(
      context: context,
      contents: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FirestoreDataModel.entryGuilds![LoginUserModel.currentGuildId]
                ['guild_name'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'GuildID: $guildId',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
