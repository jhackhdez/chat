import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/user.dart';

class AuthService with ChangeNotifier {
  User user = User(name: '', email: '', online: false, uid: '');
  bool _accessing = false;

  // Create storage
  final _storage = const FlutterSecureStorage();

  bool get accessing => _accessing;
  set accessing(bool value) {
    _accessing = value;
    // se notifica este cambio a todos los que estén escuchando
    notifyListeners();
  }

  // Getters del token de forma estática
  static Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'token');
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
      // Guardar token en lugar seguro
      await _saveToken(loginResponse.token);
      return true;
    } else {
      return false;
    }
  }

  Future register(String name, String email, String password) async {
    // Para inhabilitar botón azul
    accessing = true;

    // payload a enviar al backend
    final data = {'name': name, 'email': email, 'password': password};

    final resp = await http.post(Uri.parse('${Environment.apiUrl}/login/new'),
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    // Para habilitar botón azul despues de hacer login
    accessing = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      user = loginResponse.user;
      // Guardar token en lugar seguro
      await _saveToken(loginResponse.token);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    // Leer el token
    dynamic token = await _storage.read(key: 'token');

    try {
      final resp = await http.get(
          Uri.parse('${Environment.apiUrl}/login/renew'),
          headers: {'Content-Type': 'application/json', 'x-token': token});
      if (resp.statusCode == 200) {
        final loginResponse = loginResponseFromJson(resp.body);
        user = loginResponse.user;
        // Guardar token en lugar seguro
        await _saveToken(loginResponse.token);
        return true;
      } else {
        logout();
        return false;
      }
    } catch (e) {
      logout();
      return false;
    }
  }

  Future _saveToken(String token) async {
    // Write value
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    // Delete value
    await _storage.delete(key: 'token');
  }
}
