import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/users_service.dart';
import 'package:chat/services/chat_service.dart';

import 'package:chat/models/user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final usersService = UsersService();

  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    // Instancia de mi provider
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    final user = authService.user;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            user.name,
            style: const TextStyle(color: Colors.black87),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          // 'leading' para reservar espacio para íconos iniciales
          leading: IconButton(
            onPressed: () {
              // Desconectar el socket server
              socketService.disconnect();
              Navigator.pushReplacementNamed(context, 'login');
              AuthService.deleteToken();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.black87,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle, color: Colors.blue[400])
                  : const Icon(Icons.offline_bolt, color: Colors.red),
            )
          ],
        ),
        // Esto me permite hacer el Pull to refresh para actualizar
        // listado de usuarios conectados y no conectados
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _loadUsers,
          header: WaterDropHeader(
            complete: Icon(
              Icons.check,
              color: Colors.blue[400],
            ),
            waterDropColor: Colors.blue,
          ),
          child: _listViewUsers(),
        ));
  }

  ListView _listViewUsers() {
    // Acá se muestra el listado de usuarios en el chat. Conectados y no conectados
    return ListView.separated(
        // Para que se mire igual en iOs y Android se define el 'physics'
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) => _userListTile(users[i]),
        separatorBuilder: (_, i) => const Divider(),
        itemCount: users.length);
  }

  ListTile _userListTile(User user) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[800],
        child: Text(
          user.name.substring(0, 2),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: user.online ? Colors.green[300] : Colors.red,
            borderRadius: BorderRadius.circular(100)),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.userFor = user;
        // Navegamos a pantalla de mensajes del user seleccionado
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  _loadUsers() async {
    users = await usersService.getUsers();
    setState(() {});
    // await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
