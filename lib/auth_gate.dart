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
  String? loginUser;
  String? id;
  String? email;
  String? userName;
  String? globalUserName;
  String? avatar;

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
    print(params);

    id = params['id'];
    email = params['email'];
    userName = params['username'];
    globalUserName = params['global_name'];
    avatar = params['avatar'];
    print(id);
    print(email);
  }

  // final loginPhase = Future.sync(() async {
  //   print('POPOPO');
  //   String errorText = '';

  //   String getFragment(String url) {
  //     return Uri.parse(url).fragment;
  //   }

  //   Map<String, String> extractQueryParams(String fragment) {
  //     Map<String, String> params = {};
  //     List<String> pairs = fragment.split('&');
  //     pairs.forEach((pair) {
  //       List<String> keyValue = pair.split('=');
  //       if (keyValue.length == 2) {
  //         params[keyValue[0].replaceFirst('/auth?', '')] = keyValue[1];
  //       }
  //     });
  //     return params;
  //   }

  //   final String url = Uri.base.toString();
  //   String fragment = getFragment(url);
  //   Map<String, String> params = extractQueryParams(fragment);

  //   String? id = params['id'];
  //   String? email = params['email'];
  //   String? userName = params['username'];
  //   String? globalUserName = params['global_name'];
  //   String? avatar = params['avatar'];

  //   print('MMMM');

  //   final credential = await FirebaseAuth.instance
  //       .signInWithEmailAndPassword(email: email!, password: id!);

  //   print(credential.user);

  //   try {
  //     final credential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email!,
  //       password: id!,
  //     );

  //     await FirestoreController.setLoginUser(
  //         uid: credential.user!.uid,
  //         discordId: id,
  //         userName: userName,
  //         globalUserName: globalUserName,
  //         avatar: avatar);

  //     print('AAAA');

  //     return 'Done';
  //   } on FirebaseAuthException catch (e) {
  //     print('CCC');
  //     if (e.code == 'email-already-in-use') {
  //       final credential = await FirebaseAuth.instance
  //           .signInWithEmailAndPassword(email: email!, password: id!);

  //       await FirestoreController.setLoginUser(
  //           uid: credential.user!.uid,
  //           discordId: id,
  //           userName: userName,
  //           globalUserName: globalUserName,
  //           avatar: avatar);

  //       print('AAAA');

  //       return 'Done';
  //     }
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //       errorText = e.code;
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //       errorText = e.code;
  //     }
  //     print('BBBB');
  //     return errorText;
  //   }
  // });

  @override
  Widget build(BuildContext context) {
    print(email);
    return FutureBuilder(
      future: FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: id!)
          .onError(
            (error, stackTrace) => FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: email!, password: id!),
          ),
      builder: (context, snapshot) {
        print("👑 snapshot: ${snapshot.data}");
        if (snapshot.hasData) {
          final additionalUserInfo = snapshot.data!.additionalUserInfo;
          final userData = snapshot.data!.user;
          FirestoreController.setLoginUser(
              uid: userData?.uid ?? '',
              discordId: id,
              userName: userName,
              globalUserName: globalUserName,
              avatar: avatar);

          if (snapshot.data != 'Done') {
            Future.delayed(Duration(seconds: 3)).then((_) {
              print('3秒後に実行される');
              context.go('/login_error');
            });
          }
          Future.delayed(Duration(seconds: 3)).then((_) {
            print('3秒後に実行される');
            context.go('/home');
          });
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
