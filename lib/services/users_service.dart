import 'package:http/http.dart' as http;

import 'package:chat/services/auth_service.dart';

import 'package:chat/global/environment.dart';

import 'package:chat/models/user.dart';
import 'package:chat/models/users_response.dart';

class UsersService {
  Future<List<User>> getUsers() async {
    final token = await AuthService.getToken();
    try {
      final resp = await http.get(Uri.parse('${Environment.apiUrl}/users'),
          headers: {
            'Content-Type': 'application/json',
            'x-token': token.toString()
          });

      final usersResponse = usersResponseFromJson(resp.body);
      return usersResponse.users;
    } catch (e) {
      return [];
    }
  }
}
