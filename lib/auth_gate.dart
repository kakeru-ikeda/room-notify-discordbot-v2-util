import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? errorText;
  String? loginUser;

  String getFragment(String url) {
    return Uri.parse(url).fragment;
  }

  Map<String, String> extractQueryParams(String fragment) {
    Map<String, String> params = {};
    List<String> pairs = fragment.split('&');
    pairs.forEach((pair) {
      List<String> keyValue = pair.split('=');
      if (keyValue.length == 2) {
        params[keyValue[0].replaceFirst('/auth?', '')] = keyValue[1];
      }
    });
    return params;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future(
      () async {
        final String url = Uri.base.toString();
        String fragment = getFragment(url);
        Map<String, String> params = extractQueryParams(fragment);

        String? id = params['id'];
        String? email = params['email'];
        String? userName = params['username'];
        String? globalUserName = params['global_name'];
        String? avatar = params['avatar'];

        try {
          final credential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email!,
            password: id!,
          );

          await FirestoreController.setLoginUser(
              uid: credential.user!.uid,
              discordId: id,
              userName: userName,
              globalUserName: globalUserName,
              avatar: avatar);

          context.go('/home');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            final credential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email!, password: id!);

            await FirestoreController.setLoginUser(
                uid: credential.user!.uid,
                discordId: id,
                userName: userName,
                globalUserName: globalUserName,
                avatar: avatar);

            context.go('/home');
          }
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
            errorText = e.code;
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
            errorText = e.code;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
