import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_app/utils/socket_client.dart';

class NicknameForm extends StatefulWidget {
  @override
  _NicknameFormState createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NicknameForm> {
  String _nickname = '';

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "What's your nickname?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              placeholder: "input your nickname",
              textAlign: TextAlign.center,
              onChanged: (text) => this._nickname = text,
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                onPressed: () {
                  if (this._nickname.trim().length > 0) {
                    print("uniendose al chat...");
                    SocketClient.instance.joinToChat(this._nickname);
                  } else {
                    print("error al unirse... ${this._nickname}");
                  }
                },
                color: Colors.blue,
                child: Text("Unirse al chat"),
              ),
            )
          ],
        ));
  }
}
