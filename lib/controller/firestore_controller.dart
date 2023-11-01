import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';

class FirestoreController {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static getEntryGuilds() async {
    final docRef = db.collection('data').doc('guilds');
    final docSnapshot = await docRef.get();

    Map<String, dynamic>? data = docSnapshot.exists ? docSnapshot.data() : null;
    FirestoreDataModel.entryGuilds = data;

    print('👑 GetEntryGuilds');
    print(data);
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
}
