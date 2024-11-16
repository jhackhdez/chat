import 'package:chat/widgets/blue_btn.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';
import 'package:flutter/material.dart';

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
            onPressed: () {
              print(emailCtrl.text);
              print(passCtrl.text);
            },
          )
        ],
      ),
    );
  }
}
