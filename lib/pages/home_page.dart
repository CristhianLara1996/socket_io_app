import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:socket_io_app/utils/socket_client.dart';
import 'package:socket_io_app/widgets/chat.dart';
import 'package:socket_io_app/widgets/nickname_form.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SocketClient.instance.init();
    SocketClient.instance.connect();
  }

  @override
  void dispose() {
    SocketClient.instance.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final users = SocketClient.instance.numUsers;
          return Text("Usuarios $users");
        }),
      ),
      body: obxWidget(),
    );
  }

  Widget obxWidget() {
    return Obx(() {
      final status = SocketClient.instance.status;

      if (status.value == SocketStatus.connecting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (status.value == SocketStatus.connected) {
        return Center(
          child: NicknameForm(),
        );
      } else if (status.value == SocketStatus.joined) {
        return Chat();
      } else {
        return Center(
          child: Text("Desconectado"),
        );
      }
    });
  }

  /*Widget streamWidget() {
    return StreamBuilder<SocketStatus>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == SocketStatus.connecting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == SocketStatus.connected) {
            return Center(
              child: NicknameForm(),
            );
          } else if (snapshot.data == SocketStatus.joined) {
            return Chat();
          } else {
            return Center(
              child: Text("Desconectado"),
            );
          }
        }
        return Center(
          child: Text("Error"),
        );
      },
      initialData: SocketStatus.connecting,
      stream: SocketClient.instance.status,
    );
  }*/
}
