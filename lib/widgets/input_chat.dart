import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_app/utils/socket_client.dart';

class InputChat extends StatefulWidget {
  @override
  _InputChatState createState() => _InputChatState();
}

class _InputChatState extends State<InputChat> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: _controller,
            onChanged: SocketClient.instance.onInputChanged,
          ),
        ),
        CupertinoButton(
          onPressed: () {
            if (SocketClient.instance.sendMessage()) {
              _controller.text = "";
            }
          },
          child: Icon(Icons.send),
        )
      ],
    );
  }
}
