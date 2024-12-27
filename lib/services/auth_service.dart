import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/user.dart';

class AuthService with ChangeNotifier {
  User user = User(name: '', email: '', online: false, uid: '');
  bool _accessing = false;

  bool get accessing => _accessing;
  set accessing(bool value) {
    _accessing = value;
    // se notifica este cambio a todos los que estén escuchando
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Para inhabilitar botón azul
    accessing = true;

    // payload a enviar al backend
    final data = {'email': email, 'password': password};

    final resp = await http.post(Uri.parse('${Environment.apiUrl}/login'),
        body: jsonEncode(data), headers: {'Content-type': 'application/json'});

    // Para habilitar botón azul despues de hacer login
    accessing = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      user = loginResponse.user;
      // TODO: Guardar token en lugar seguro
      return true;
    } else {
      return false;
    }
  }
}
