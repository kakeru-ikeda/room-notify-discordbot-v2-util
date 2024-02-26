import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/controller/shared_preference_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/login_user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? loginUser;
  String? id;
  String? email;
  String? userName;
  String? globalUserName;
  String? avatar;
  String? demoMode;

  String getFragment(String url) {
    return Uri.parse(url).fragment;
  }

  Map<String, String> extractQueryParams(String fragment) {
    Map<String, String> params = {};
    List<String> pairs = fragment.split('&');
    pairs.forEach((pair) {
      List<String> keyValue = pair.split('=');
      if (keyValue.length == 2) {
        params[keyValue[0].replaceFirst('/auth/?', '')] = keyValue[1];
      }
    });
    return params;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('👑 InitState');

    final String url = Uri.base.toString();
    String fragment = getFragment(url);
    Map<String, String> params = extractQueryParams(fragment);

    demoMode = params['demo'];

    if (demoMode == 'true') {
      print('👑 DemoMode');
      id = 'demouser';
      email = 'demo@demo.com';
      userName = 'DemoUser';
      globalUserName = 'DemoUser';
      avatar = '';
      LoginUserModel.currentGuildId = '1208808403925991434';
      Future(
        () async {
          await SharedPreferencesController.instance.saveBoolData('demo', true);
        },
      );
    } else {
      id = params['id'];
      email = params['email'];
      userName = Uri.decodeFull(params['username'] ?? '');
      globalUserName = Uri.decodeFull(params['global_name'] ?? '');
      avatar = params['avatar'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: id!)
          .onError(
            (error, stackTrace) => FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: email!, password: id!),
          ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.user;
          FirestoreController.setLoginUser(
              uid: userData?.uid ?? '',
              discordId: id,
              userName: userName,
              globalUserName: globalUserName,
              avatar: avatar);

          Future.delayed(const Duration(seconds: 2)).then((_) {
            context.go('/home');
          });
        }
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 6,
            ),
            Text(
              'ログインを検証中...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        );
      },
    );
  }
}
