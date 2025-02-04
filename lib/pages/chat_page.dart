import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/auth_service.dart';

import 'package:chat/models/messages_response.dart';
import 'package:chat/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// 'TickerProviderStateMixin' se utiliza para poder reproducir la animación de las burbujas de msjs
class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  final List<ChatMessage> _messages = [];

  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    // Escuchar mensaje que viene desde el server
    socketService.socket.on('personal-msg', _listenMessage);
    // Cargar historial de mensajes
    _loadHistory(chatService.userFor.uid);
  }

  Future<void> _loadHistory(String userID) async {
    List<Message> chats = await chatService.getChat(userID);
    final history = chats.map((message) => ChatMessage(
          text: message.text,
          uid: message.from,
          // ..forward() lanza inmediatamente la animación
          animationController: AnimationController(
              vsync: this, duration: const Duration(milliseconds: 0))
            ..forward(),
        ));

    // Inserta los mensajes en el array de mensajes, que serán los que se muestren al abrir el chat
    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic payload) {
    if (payload['from'] != chatService.userFor.uid &&
        payload['from'] != authService.user.uid) {
      return;
    }
    ChatMessage message = ChatMessage(
        text: payload['text'],
        uid: payload['to'],
        animationController: AnimationController(
            vsync: this, duration: const Duration(milliseconds: 300)));

    setState(() {
      _messages.insert(0, message);
    });

    // Mandar a correr la animación
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userFor = chatService.userFor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              maxRadius: 14,
              child: Text(
                userFor.name.substring(0, 2),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              userFor.name,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
        centerTitle: true,
        elevation: 3,
      ),
      body: Column(
        children: [
          // Este widget 'Flexible' tiene la capacidad de expandirse cuando tiene mucho contenido dentro
          // y es el que permitirá hacer scroll hacia arriba para ver hitórico de msjs
          Flexible(
              child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _messages[i],
            reverse: true,
          )),
          const Divider(
            height: 5,
          ),
          // Caja de texto para escribir los msj
          Container(
            color: Colors.white,
            child: _inputChat(),
          )
        ],
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            controller: _textController,
            onSubmitted: _handleSubmit,
            onChanged: (texto) {
              // Se cambia estado de variable '_isWriting' cuando se está escribiendo
              setState(() {
                if (texto.trim().isNotEmpty) {
                  _isWriting = true;
                } else {
                  _isWriting = false;
                }
              });
            },
            decoration:
                const InputDecoration.collapsed(hintText: 'Send message'),
            focusNode: _focusNode,
          )),
          // Botón de enviar
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _isWriting
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                      child: const Text('Enviar'),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          onPressed: _isWriting
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ))
        ],
      ),
    ));
  }

  _handleSubmit(String text) {
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text,
      uid: authService.user.uid,
      // el 'this' sale disponible solo si se mezcló la clase principal con 'TickerProviderStateMixin'
      animationController: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 200)),
    );
    _messages.insert(0, newMessage);
    // para que se ejecute la animación
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    // Acá es donde se envía mensaje al servidor de socket
    socketService.emit('personal-msg', {
      // Acá se define el que envía el msg, el destinatario del msg y el texto del msg
      'from': authService.user.uid,
      'to': chatService.userFor.uid,
      'text': text
    });
  }

  @override
  void dispose() {
    // Limpiar cada una de las instancias que tenemos en el array de msjs
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    // dejar de escuchar mensajes al salir
    socketService.socket.off('personal-msg');

    super.dispose();
  }
}
