import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/style/text_style_template.dart';

import '../model/firestore_data_model.dart';
import '../model/login_user_model.dart';

class PageTemplate {
  static setPageTitle({required String title, required String caption}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyleTemplate.pageTitle,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(caption),
        ),
      ],
    );
  }

  static setGuildInfoTitle({String? guildId}) {
    guildId = guildId ?? LoginUserModel.currentGuildId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Image.network(
            "https://cdn.discordapp.com/icons/$guildId/${FirestoreDataModel.entryGuilds![guildId]['guild_icon']}.png",
            height: 75,
            width: 75,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FirestoreDataModel.entryGuilds![guildId]['guild_name'],
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
          )
        ],
      ),
    );
  }
}
