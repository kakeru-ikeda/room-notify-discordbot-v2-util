import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class CardUser extends StatefulWidget {
  CardUser({
    super.key,
    required this.guildId,
    required this.userData,
  });
  final String guildId;
  final Map<String, dynamic> userData;

  @override
  State<CardUser> createState() => _CardUserState();
}

class _CardUserState extends State<CardUser> {
  @override
  Widget build(BuildContext context) {
    final guildId = widget.guildId;

    final discriminator = widget.userData['discriminator'];
    final userId = widget.userData['user_id'];
    final userGlobalName =
        widget.userData['user_global_name'] ?? widget.userData['user_name'];
    final userName = discriminator == '0'
        ? widget.userData['user_name']
        : "$userGlobalName#$discriminator";
    final avatar = widget.userData['avatar'];
    final bool isAdmin = widget.userData['is_admin'];
    final state = widget.userData['state'];

    final avatarUrl = avatar != null
        ? "https://cdn.discordapp.com/avatars/$userId/$avatar.png"
        : "https://play-lh.googleusercontent.com/McVkTazCaveLwqoDuX_E7ayTgdK4DPbrKCGcPSIZT4b783j6HJvJYu0uxQAuzCw7BCs=w240-h480-rw";

    final List<String> choices = <String>['メンバー', '管理者'];
    String isSelectedValue = isAdmin ? choices.last : choices.first;

    print(isAdmin.toString());

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(
                avatarUrl,
                height: 50,
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Text(
                      userGlobalName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          StatefulBuilder(
            builder: (context, changeValue) {
              return DropdownButton(
                items: choices.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: isSelectedValue,
                onChanged: (value) {
                  FirestoreController.setGuildUserInfo(
                      guildId: guildId,
                      userId: userId,
                      field: 'is_admin',
                      data: value == '管理者' ? true : false);
                  changeValue(() {
                    isSelectedValue = value!;
                  });
                },
              );
            },
          )
        ],
      ),
    );
  }
}
