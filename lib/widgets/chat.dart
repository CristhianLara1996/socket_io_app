import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_app/models/chat_message.dart';
import 'package:socket_io_app/utils/socket_client.dart';
import 'package:socket_io_app/widgets/input_chat.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(
              () {
                final messages = SocketClient.instance.messages;
                return ListView.builder(
                  itemBuilder: (_, index) {
                    final ChatMessage message = messages[index];
                    return ListTile(
                      title: Text(message.message),
                    );
                  },
                  itemCount: messages.length,
                );
              },
            ),
          ),
          Obx(() {
            final typingUser = SocketClient.instance.typingUsers;
            if (typingUser == null) {
              return Container(
                height: 0,
              );
            }

            return Text(
              "$typingUser is Typing",
              style: TextStyle(color: Colors.black26),
            );
          }),
          InputChat(),
        ],
      ),
    );
  }
}
