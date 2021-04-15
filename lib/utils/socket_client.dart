import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:socket_io_app/models/chat_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

enum SocketStatus {
  connecting,
  connected,
  joined,
  disconnected,
  error,
}

class SocketClient {
  SocketClient._internal();
  static SocketClient _instance = SocketClient._internal();
  static SocketClient get instance => _instance;

  RxInt _numUsers = 0.obs;
  RxInt get numUsers => _numUsers;

  RxString _inputText = "".obs;
  RxMap<String, String> _typingUsers = Map<String, String>().obs;

  String get typingUsers {
    if (_typingUsers.values.length > 0) {
      return this._typingUsers.values.last;
    }
    return null;
  }

  Rx<SocketStatus> _status = SocketStatus.connecting.obs;
  Rx<SocketStatus> get status => _status;

  RxList<ChatMessage> _messages = List<ChatMessage>().obs;
  RxList<ChatMessage> get messages => _messages;

  Worker _typingWorker;

  /*
  StreamController<SocketStatus> _statusController =
      StreamController.broadcast();

  Stream<SocketStatus> get status => _statusController.stream;
*/

  IO.Socket _socket;
  String _nickname;

  void init() {
    /*ever(this._inputText, (_) {
      print(_inputText.value);
    });*/

    debounce(this._inputText, (_) {
      print("debound ${_inputText.value}");
      this._socket?.emit('stop typing');
      this._typingWorker = null;
    }, time: Duration(milliseconds: 500));
  }

  void connect() {
    this._socket =
        IO.io('https://socketio-chat-h9jt.herokuapp.com/', <String, dynamic>{
      'transports': ['websocket'],
    });

    this._socket.on('connect', (_) {
      print("😎 conectado");
      //this._statusController.sink.add(SocketStatus.connected);
      this._status.value = SocketStatus.connected;
    });

    this._socket.on('connect_error', (_) {
      print("😪 error $_");
      //this._statusController.sink.add(SocketStatus.error);
      this._status.value = SocketStatus.error;
    });

    this._socket.on('disconnect', (_) {
      print("😪 disconnect $_");
      this._status.value = SocketStatus.disconnected;
      // this._statusController.sink.add(SocketStatus.disconnected);
    });

    this._socket.on('login', (data) {
      print("😛 $data");
      final int numUsers = data['numUsers'];
      this._numUsers.value = numUsers;
      this._status.value = SocketStatus.joined;
      // this._statusController.sink.add(SocketStatus.joined);
    });

    this._socket.on('user joined', (data) {
      print("😛 usuario unido $data");
      this._numUsers.value = data['numUsers'] as int;
      // this._statusController.sink.add(SocketStatus.joined);
    });

    this._socket.on('typing', (data) {
      final String username = data['username'];
      this._typingUsers.add(username, username);
      // this._statusController.sink.add(SocketStatus.joined);
    });

    this._socket.on('stop typing', (data) {
      final String username = data['username'];
      this._typingUsers.remove(username);
    });

    this._socket.on('user left', (data) {
      showSimpleNotification(
        Text("${data['username']} left"),
        background: Colors.red,
      );
      this._numUsers.value = data['numUsers'] as int;
    });

    this._socket.on('new message', (data) {
      print("😁 $data");
      final String username = data['username'];
      final String message = data['message'];
      if (message != null && message.length > 0) {
        this.messages.add(ChatMessage(
              username: username,
              message: message,
              sender: false,
            ));
      }
    });
  }

  void joinToChat(String nickname) {
    this._nickname = nickname;
    this._socket?.emit('add user', nickname);
  }

  void onInputChanged(String texto) {
    if (this._typingWorker == null) {
      this._typingWorker = once(this._inputText, (_) {
        print("start typing");
        this._socket?.emit('typing');
      });
    }

    this._inputText.value = texto;
  }

  bool sendMessage() {
    final text = this._inputText.value;
    if (text.trim().length > 0) {
      this._socket?.emit('new message', text);
      this._inputText.value = '';
      final message = ChatMessage(
        username: this._nickname,
        message: text,
        sender: true,
      );
      this._messages.add(message);
      return true;
    }
    return false;
  }

  void disconnect() {
    this._socket?.disconnect();
    this._socket = null;
  }
}
