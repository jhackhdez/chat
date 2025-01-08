import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';

import 'package:chat/helpers/show_alert.dart';

import 'package:chat/widgets/blue_btn.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // color del background de la pantalla
        backgroundColor: const Color(0xffF2F2F2),
        // se define 'SafeArea' para establecer un margen superior y la
        // imagen no quede muy pegada al top
        body: SafeArea(
          // Permite hacer scroll cuando sale el teclado en pantalla y decrece la misma
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              // Este 'height' va a ser igual al 90% del largo de la pantalla
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                // 'MainAxisAlignment.spaceBetween' para que se esparzan los elementos en toda la pantalla
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Logo(
                    title: 'Mensseger',
                  ),
                  _Form(),
                  const Labels(
                    route: 'register',
                    title: '¿No tienes cuenta?',
                    subTitle: 'Crea una ahora!',
                  ),
                  const Text('Términos y condiciones de uso',
                      style: TextStyle(fontWeight: FontWeight.w200))
                ],
              ),
            ),
          ),
        ));
  }
}

// Se define 'StatefulWidget' porque este Form de user y pass
// debe cambiar su estado al utilizarse
class _Form extends StatefulWidget {
  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          // TextField Email
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Email',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          // TextField Password
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Password',
            textController: passCtrl,
            isPassword: true,
          ),

          // Button
          BlueBtn(
            text: 'Ingrese',
            onPressed: authService.accessing
                ? null
                : () async {
                    // Para eliminar el focues en donde esté y esto oculta teclado
                    FocusScope.of(context).unfocus();
                    // Se llama a authService
                    final loginOK = await authService.login(
                        emailCtrl.text.trim(), passCtrl.text.trim());

                    if (loginOK) {
                      // TODO: Conectar a nuestro socket server
                      // Navegar a otra pantalla
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, 'users');
                    } else {
                      // Mostrar alerta
                      showAlert(
                          // ignore: use_build_context_synchronously
                          context,
                          'Login incorrecto',
                          'Revise credenciales');
                    }
                  },
          )
        ],
      ),
    );
  }
}
