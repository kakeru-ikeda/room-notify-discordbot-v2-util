import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/modal_contents.dart';

class CardGuild {
  static setCard({
    required guildId,
    required guildName,
    required guildIcon,
    required guildState,
  }) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(
                  "https://cdn.discordapp.com/icons/$guildId/$guildIcon.png"),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guildName,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'GuildID: $guildId',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              guildState ? 'Enable' : 'Disable',
              style: TextStyle(color: guildState ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  static showGuildInfoModal({
    required BuildContext context,
    required guildId,
    required guildName,
    required guildIcon,
    required guildState,
    bool edit = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      constraints: BoxConstraints.expand(),
      builder: (BuildContext context) {
        return ModalContents(
          context: context,
          guildId: guildId,
          guildName: guildName,
          guildIcon: guildIcon,
          guildState: guildState,
        );
      },
    );
  }

  static Future<bool> _modalWillPop() async {
    print('👑 Willpop');
    return true;
  }
}
