import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('ぽまえは登録されてないぜ'),
          ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            child: Text('ログイン'),
          ),
        ],
      ),
    );
  }
}
