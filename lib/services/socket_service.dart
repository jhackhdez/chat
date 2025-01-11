import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:chat/global/environment.dart';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

// enum para manejar estados del Server
enum ServerStatus { Online, Offline, Connecting }

// "ChangeNotifier" ayuda a comunicar a provider cuando refrescar UI o
// interfaz de usuario o redibujar algún widget si hay algún cambio.

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {
    // Obtengo token desde AuthService
    final token = await AuthService.getToken();

    // Dart client
    _socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': token}
    });

    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
