import 'package:chat/models/messages_response.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:chat/services/auth_service.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/models/user.dart';

class ChatService with ChangeNotifier {
  User userFor = User(name: '', email: '', online: false, uid: '');

  Future<List<Message>> getChat(String userID) async {
    final token = await AuthService.getToken();
    final resp = await http
        .get(Uri.parse('${Environment.apiUrl}/messages/$userID'), headers: {
      'Content-Type': 'application/json',
      'x-token': token.toString()
    });

    final messagesResp = messagesResponseFromJson(resp.body);

    return messagesResp.messages;
  }
}
