import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:room_notify_discordbot_v2_util/auth_gate.dart';
import 'package:room_notify_discordbot_v2_util/controller/firestore_controller.dart';
import 'package:room_notify_discordbot_v2_util/model/firestore_data_model.dart';
import 'package:room_notify_discordbot_v2_util/pages/auth/auth_error_page.dart';
import 'package:room_notify_discordbot_v2_util/pages/index.dart';
import 'dart:html' as html;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const Center(
          child: CircularProgressIndicator(),
        );
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
            html.window.open(
              'https://discord.com/api/oauth2/authorize?client_id=1166005725886156860&redirect_uri=https%3A%2F%2Fus-central1-room-notify-v2.cloudfunctions.net%2FdiscordAuth%2Fdiscord-redirect&response_type=code&scope=identify%20guilds%20email',
              '_self',
            );
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
