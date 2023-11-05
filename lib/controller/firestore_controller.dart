import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';

class FirestoreController {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static getEntryGuilds() async {
    final docRef = db.collection('data').doc('guilds');
    final docSnapshot = await docRef.get();

    Map<String, dynamic>? data = docSnapshot.exists ? docSnapshot.data() : null;
    print(data);
    FirestoreDataModel.entryGuilds = data;

    print('👑 GetEntryGuilds');
    print(FirestoreDataModel.entryGuilds);
  }

  static Future<Map<String, dynamic>?> getGuildInfo(
      {required String guildId}) async {
    final docRef = db
        .collection('data')
        .doc('guilds')
        .collection(guildId)
        .doc('guild_info');
    final docSnapshot = await docRef.get();

    final data = docSnapshot.exists ? docSnapshot.data() : null;
    print('👑 GetGuildInfo');
    return data;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getGuildUsers(
      {required String guildId}) {
    final docRef = db.collection('data').doc('users').collection(guildId);
    final snapshots = docRef.snapshots();
    //final docSnapshot = await docRef.get();

    // final data = docSnapshot.exists ? docSnapshot.data() : null;
    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getGuildChannels(
      {required guildId}) {
    final docRef = db.collection('data').doc('channels').collection(guildId);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      getSubjectEnabledForChannels({required guildId}) {
    final docRef = db
        .collection('data')
        .doc('channels')
        .collection(guildId)
        .where('subject', isNotEqualTo: '');
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static void setGuildInfo(
      {required guildId, required field, required data}) async {
    final docRef = db.collection('data').doc('guilds');

    await docRef.update({'$guildId.$field': data});
  }

  static void setGuildUserInfo(
      {required guildId,
      required userId,
      required field,
      required data}) async {
    final docRef =
        db.collection('data').doc('users').collection(guildId).doc(userId);

    await docRef.update({field: data});
  }

  static void setChannelInfo(
      {required guildId,
      required channelId,
      required field,
      required data}) async {
    final docRef = db
        .collection('data')
        .doc('channels')
        .collection(guildId)
        .doc(channelId);

    await docRef.update({field: data});
  }
}
