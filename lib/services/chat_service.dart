import 'package:flutter/material.dart';
import 'package:chat/models/user.dart';

class ChatService with ChangeNotifier {
  User userFor = User(name: '', email: '', online: false, uid: '');
}
