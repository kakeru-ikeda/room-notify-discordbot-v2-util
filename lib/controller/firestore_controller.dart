import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_notify_discordbot_v2_util/controller/shared_preference_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreController {
  static SharedPreferencesController prefs =
      SharedPreferencesController.instance;

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static getEntryGuilds() async {
    final docRef = db.collection('data').doc('guilds');
    final docSnapshot = await docRef.get();

    Map<String, dynamic>? data = docSnapshot.exists ? docSnapshot.data() : null;
    SplayTreeMap<String, dynamic> entryGuilds = SplayTreeMap.from(
        data!, (a, b) => a.toString().compareTo(b.toString()));
    FirestoreDataModel.entryGuilds = entryGuilds;

    print('👑 GetEntryGuilds');
    print(FirestoreDataModel.entryGuilds);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getGuildData() {
    final docRef = db.collection('data').doc('guilds');
    final data = docRef.get();

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

  static Future<DocumentSnapshot<Map<String, dynamic>>> getGuildEntryUser(
      {required String guildId, required String userId}) {
    final docRef =
        db.collection('data').doc('users').collection(guildId).doc(userId);
    final data = docRef.get();

    return data;
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

  static getCurrentNotifyChannelData({required guildId}) async {
    final docRef = db
        .collection('data')
        .doc('room_notify')
        .collection('notify_channel')
        .doc('default');
    final docSnapshot = await docRef.get();

    Map<String, dynamic> data = docSnapshot.data()!;
    return data[guildId];
  }

  static setCurrentNotifyChannelData(
      {required guildId, required channelId, required channelName}) async {
    final docRef = db
        .collection('data')
        .doc('room_notify')
        .collection('notify_channel')
        .doc('default');
    final docSnapshot = await docRef.get();

    Map<String, dynamic> data = docSnapshot.data()!;
    data[guildId] = {
      'channel_id': channelId,
      'channel_name': channelName,
    };

    await docRef.update(data);
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>>? getRoomNotify(
      {required guildId, required week}) {
    print('👑 $guildId');
    final docRef =
        db.collection('data').doc('room_notify').collection(guildId).doc(week);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getRoomNotifyHome(
      {required guildId, required week}) {
    final docRef = db
        .collection('data')
        .doc('room_notify')
        .collection(guildId)
        .where('state', isEqualTo: true);
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
      {required guildId, bool isEnabled = false}) {
    final docRef = isEnabled
        ? db
            .collection('notice')
            .doc('kadai')
            .collection(guildId)
            // .orderBy('deadline', descending: false)
            .where('state', isEqualTo: true)
        : db
            .collection('notice')
            .doc('kadai')
            .collection(guildId)
            .orderBy('deadline', descending: false);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getKadaiHome(
      {required guildId,
      bool isEnabled = false,
      remindStartDate,
      remindLastDate}) {
    final docRef = isEnabled
        ? db
            .collection('notice')
            .doc('kadai')
            .collection(guildId)
            // .orderBy('deadline', descending: false)
            .where('deadline', isLessThan: remindStartDate)
            .where('deadline', isGreaterThan: remindLastDate)
        : db
            .collection('notice')
            .doc('kadai')
            .collection(guildId)
            .orderBy('deadline', descending: false);
    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getReminds(
      {required guildId, bool isEnabled = false}) {
    Query<Map<String, dynamic>> docRef = isEnabled
        ? db
            .collection('notice')
            .doc('remind')
            .collection(guildId)
            .where('state', isEqualTo: true)

        // .orderBy('deadline', descending: false)
        : db
            .collection('notice')
            .doc('remind')
            .collection(guildId)
            .orderBy('deadline', descending: false);

    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getRemindsHome({
    required guildId,
    bool isEnabled = false,
    remindStartDate,
    remindLastDate,
  }) {
    Query<Map<String, dynamic>> docRef = isEnabled
        ? db
            .collection('notice')
            .doc('remind')
            .collection(guildId)
            .where('deadline', isLessThan: remindStartDate)
            .where('deadline', isGreaterThan: remindLastDate)
        // .orderBy('deadline', descending: false)
        : db
            .collection('notice')
            .doc('remind')
            .collection(guildId)
            .orderBy('deadline', descending: false);

    final snapshots = docRef.snapshots();

    return snapshots;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getSlackExternal(
      {required guildId}) {
    final docRef =
        db.collection('data').doc('slack_external').collection(guildId);
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
    bool isUpdate = false,
  }) async {
    final docRef =
        db.collection('notice').doc('kadai').collection(guildId).doc(kadaiId);

    if (isUpdate) {
      print('👑 Update');
      await docRef.update(data);
    } else {
      await docRef.set(data);
    }
  }

  static setRemindInfo({
    required guildId,
    required remindId,
    required Map<String, dynamic> data,
    bool isUpdate = false,
  }) async {
    final docRef =
        db.collection('notice').doc('remind').collection(guildId).doc(remindId);

    if (isUpdate) {
      print('👑 Update');
      await docRef.update(data);
    } else {
      await docRef.set(data);
    }
  }

  static setLoginUser({
    required uid,
    required discordId,
    required userName,
    required globalUserName,
    required avatar,
  }) async {
    final docRef = db.collection('login_user').doc(uid);

    await docRef.set({
      'id': discordId,
      'user_name': userName,
      'user_global_name': globalUserName,
      'avatar': avatar
    });

    await prefs.saveData('userId', discordId);
    await prefs.saveData('userName', globalUserName);
    await prefs.saveData('avatar', avatar);

    LoginUserModel.userId = discordId;
    LoginUserModel.userName = globalUserName;
    LoginUserModel.avatar = avatar;
  }

  static setLoginUserData({
    required uid,
    required currentGuildId,
    required currentGuildName,
  }) async {
    final docRef = db
        .collection('login_user')
        .doc(uid)
        .collection('user_data')
        .doc('current');

    await docRef.set({
      'guild_id': currentGuildId,
      'guild_name': currentGuildName,
    });

    await prefs.saveData('currentGuildId', currentGuildId);
    await prefs.saveData('currentGuildName', currentGuildName);

    LoginUserModel.currentGuildId = currentGuildId;
    LoginUserModel.currentGuildName = currentGuildName;
  }

  static setSlackExternalData(
      {required guildId,
      required slackexternalId,
      required slackToken,
      required channelId,
      required subject}) async {
    final docRef = db
        .collection('data')
        .doc('slack_external')
        .collection(guildId)
        .doc(slackexternalId);

    docRef.set({
      'id': slackexternalId,
      'slack_token': slackToken,
      'channel_id': channelId,
      'subject': subject,
      'state': true,
    });
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

  static removeRemind({required guildId, required remindId}) {
    final docRef =
        db.collection('notice').doc('remind').collection(guildId).doc(remindId);

    docRef.delete();
  }

  static removeSlackExternal({required guildId, required slackexternalId}) {
    final docRef = db
        .collection('data')
        .doc('slack_external')
        .collection(guildId)
        .doc(slackexternalId);

    docRef.delete();
  }
}
