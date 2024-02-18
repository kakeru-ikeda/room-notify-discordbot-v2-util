import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/auth_gate.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/controller/shared_preference_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/auth/auth_error_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/auth/user_undefind_error_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/home/home_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/index.dart';
import 'dart:html' as html;
import 'firebase_options.dart';

String? userId;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferencesController prfs = SharedPreferencesController.instance;
  userId = await prfs.getData('userId');
  print('👑 User ID: $userId');

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 2)),
            builder: (context, snapshot) {
              print("👑 ${state.extra}");
              String getFragment(String url) {
                return Uri.parse(url).fragment;
              }

              Map<String, String> extractQueryParams(String fragment) {
                Map<String, String> params = {};
                List<String> pairs = fragment.split('&');
                pairs.forEach((pair) {
                  List<String> keyValue = pair.split('=');
                  if (keyValue.length == 2) {
                    params[keyValue[0].replaceFirst('/auth/?', '')] =
                        keyValue[1];
                  }
                });
                return params;
              }

              if (userId != null) {
                context.pushReplacement('/home');
              }

              Future.delayed(const Duration(seconds: 5)).then((_) async {
                SharedPreferencesController prfs =
                    SharedPreferencesController.instance;
                userId = await prfs.getData('userId');
                print('💎 User ID: $userId');

                final String url = Uri.base.toString();
                String fragment = getFragment(url);
                Map<String, String> params = extractQueryParams(fragment);

                print('👑 params: ${params}');

                String? demoMode = params['demo'];
                if (demoMode == 'true') {
                  print('👑 DemoMode');
                  context.go('/demo');
                  return;
                }

                if (userId == null) {
                  context.go('/login');
                  return;
                }
              });

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    'お待ち下さい...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              );
            });
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'auth',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthGate();
          },
        ),
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const IndexPage();
          },
        ),
        GoRoute(
          path: 'login',
          builder: (context, state) {
            if (kDebugMode) {
              html.window.open(
                  'https://discord.com/api/oauth2/authorize?client_id=1166005725886156860&redirect_uri=https%3A%2F%2Fus-central1-room-notify-v2.cloudfunctions.net%2FdiscordAuth%2Fdevelop&response_type=code&scope=guilds%20email%20identify',
                  '_self');
            } else {
              html.window.open(
                  'https://discord.com/api/oauth2/authorize?client_id=1166005725886156860&redirect_uri=https%3A%2F%2Fus-central1-room-notify-v2.cloudfunctions.net%2FdiscordAuth%2Frelease&response_type=code&scope=guilds%20email%20identify',
                  '_self');
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        GoRoute(
          path: 'login_error',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthErrorPage();
          },
        ),
        GoRoute(
          path: 'user_undefind',
          builder: (BuildContext context, GoRouterState state) {
            return const UserUndefindErrorPage();
          },
        ),
        GoRoute(
          path: 'demo',
          builder: (context, state) {
            String id = 'demouser';
            String email = 'demo@demo.com';
            String userName = 'DemoUser';
            String globalUserName = 'DemoUser';
            String avatar = '';
            Future(() async {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: id)
                  .then((value) {
                final userData = value.user;

                FirestoreController.setLoginUser(
                    uid: userData?.uid ?? '',
                    discordId: id,
                    userName: userName,
                    globalUserName: globalUserName,
                    avatar: avatar);
              });
            });

            return const HomePage();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '教室通知くんv2 - ユーティリティ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
