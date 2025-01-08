import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:chat/services/auth_service.dart';

import 'package:chat/helpers/show_alert.dart';

import 'package:chat/widgets/blue_btn.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                    title: 'Register',
                  ),
                  _Form(),
                  const Labels(
                    route: 'login',
                    title: '¿Ya tienes cuenta?',
                    subTitle: 'Ingresa ahora!',
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
  final nameCtrl = TextEditingController();
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
          // TextField Name
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Name',
            keyboardType: TextInputType.text,
            textController: nameCtrl,
          ),
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
            text: 'Crear cuenta',
            onPressed: authService.accessing
                ? null
                : () async {
                    print(nameCtrl.text);
                    print(emailCtrl.text);
                    print(passCtrl.text);
                    final registerOK = await authService.register(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passCtrl.text.trim());

                    if (registerOK == true) {
                      // TODO: Conectar socket server
                      Navigator.pushReplacementNamed(context, 'users');
                    } else {
                      showAlert(context, 'Registro Incorrecto', registerOK);
                    }
                  },
          )
        ],
      ),
    );
  }
}
