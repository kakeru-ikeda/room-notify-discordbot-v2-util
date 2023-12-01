import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          'https://cdn.discordapp.com/attachments/982998698239852634/1178219963539005501/error.png?ex=657559d9&is=6562e4d9&hm=aeb127da8156af676104c00357e3d197dba1e7afb250b6713900c97a2a2081e3&',
          height: 128,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Discordの認証に失敗しました',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text('ログイン'),
        ),
      ],
    );
  }
}
