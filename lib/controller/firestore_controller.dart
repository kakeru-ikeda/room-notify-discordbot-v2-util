import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    final result = docRef.snapshots();

    return result;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getGuildChannelsData(
      {required guildId}) async {
    final docRef = db.collection('data').doc('channels').collection(guildId);
    final result = await docRef.get();

    return result;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getRoomNotify(
      {required guildId, required week}) {
    final docRef =
        db.collection('data').doc('room_notify').collection(guildId).doc(week);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getTeachers(
      {required guildId}) {
    final docRef = db
        .collection('data')
        .doc('teachers')
        .collection(guildId)
        .orderBy('entry_date', descending: false);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getKadai(
      {required guildId}) {
    final docRef = db
        .collection('notice')
        .doc('kadai')
        .collection(guildId)
        .orderBy('deadline', descending: false);
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

  static setRoomNotifyInfo(
      {required guildId, required week, required field, required data}) async {
    final docRef =
        db.collection('data').doc('room_notify').collection(guildId).doc(week);

    await docRef.update({field: data});
  }

  static setTeacherInfo(
      {required guildId,
      required doc,
      required field,
      required data,
      bool? isUpdate}) async {
    final docRef =
        db.collection('data').doc('teachers').collection(guildId).doc(doc);

    if (isUpdate != null && isUpdate) {
      await docRef.update({field: data});
    } else {
      await docRef.set({field: data});
    }
  }

  static setKadaiInfo({
    required guildId,
    required kadaiId,
    required Map<String, dynamic> data,
  }) async {
    final docRef =
        db.collection('notice').doc('kadai').collection(guildId).doc(kadaiId);

    await docRef.set(data);

    // for (var element in data.entries) {
    //   await docRef.set({element.key: element.value});
    //   // element == data.entries.first
    //   //     ? await docRef.set({element.key: element.value})
    //   //     : await docRef.update({element.key: element.value});
    // }
  }

  static removeTeacher({required guildId, required teacherName}) {
    final docRef = db
        .collection('data')
        .doc('teachers')
        .collection(guildId)
        .doc(teacherName);

    docRef.delete();
  }

  static removeKadai({required guildId, required kadaiId}) {
    final docRef =
        db.collection('notice').doc('kadai').collection(guildId).doc(kadaiId);

    docRef.delete();
  }
}
