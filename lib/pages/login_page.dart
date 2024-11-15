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
          child: Column(
            // 'MainAxisAlignment.spaceBetween' para que se esparzan los elementos en toda la pantalla
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Logo(),
              _Form(),
              _Labels(),
              const Text('Términos y condiciones de uso',
                  style: TextStyle(fontWeight: FontWeight.w200))
            ],
          ),
        ));
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(top: 50),
        child: const Column(
          children: [
            Image(image: AssetImage('assets/tag-logo.png')),
            SizedBox(height: 20),
            Text(
              'Messenger',
              style: TextStyle(fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}

// Se define 'StatefulWidget' porque este Form de user y pass
// debe cambiar su estado al utilizarse
class _Form extends StatefulWidget {
  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(),
          TextField(),
          ElevatedButton(
            onPressed: () {},
            child: null,
          )
        ],
      ),
    );
  }
}

class _Labels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('¿No tienes cuenta?',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w300)),
        const SizedBox(height: 10),
        Text(
          'Crea una ahora!',
          style: TextStyle(
              color: Colors.blue[600],
              fontSize: 18,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
