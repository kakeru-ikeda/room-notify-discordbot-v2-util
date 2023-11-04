import 'dart:convert' as convert;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/card_user.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';

class UserList extends StatefulWidget {
  const UserList({super.key, required this.guildId});
  final String guildId;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late String guildId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    guildId = widget.guildId;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreController.getGuildUsers(guildId: guildId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: 600,
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs
                    .map(
                      (user) =>
                          CardUser(guildId: guildId, userData: user.data()),
                    )
                    .toList(),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
