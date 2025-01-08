import 'package:chat/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';

import 'package:chat/pages/users_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          return const Center(
            // TODO: Adicionar una animación
            child: Text('Loading...'),
          );
        },
        future: checkLoginState(context),
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    // no se necesita que se redibuje pantalla, por eso 'listen: false'
    final authService = Provider.of<AuthService>(context, listen: false);

    final authenticated = await authService.isLoggedIn();

    if (authenticated) {
      // TODO: Conectar al socket server
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (
                _,
                __,
                ___,
              ) =>
                  const UsersPage(),
              transitionDuration: const Duration(milliseconds: 0)));
    } else {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (
                _,
                __,
                ___,
              ) =>
                  const LoginPage(),
              transitionDuration: const Duration(milliseconds: 0)));
    }
  }
}
