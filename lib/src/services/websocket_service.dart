import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketMessage {
  final String event;
  final dynamic data;

  WebSocketMessage({required this.event, this.data});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      event: json['event'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'event': event,
        'data': data,
      };
}

class WebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl;
  final String? token;
  final _messageController = StreamController<WebSocketMessage>.broadcast();

  WebSocketService(this.baseUrl, {this.token});

  Stream<WebSocketMessage> get messages => _messageController.stream;

  void connect() {
    final uri = Uri.parse(baseUrl.replaceFirst('http', 'ws'));
    _channel = WebSocketChannel.connect(uri);

    // اتصال اولیه و ارسال توکن
    if (token != null) {
      _channel?.sink.add(json.encode({
        'event': 'auth',
        'data': {'token': token}
      }));
    }

    // دریافت پیام‌ها
    _channel?.stream.listen(
      (message) {
        final data = json.decode(message);
        _messageController.add(WebSocketMessage.fromJson(data));
      },
      onError: (error) {
        print('WebSocket Error: $error');
        reconnect();
      },
      onDone: () {
        print('WebSocket Connection Closed');
        reconnect();
      },
    );
  }

  void send(String event, dynamic data) {
    if (_channel != null) {
      final message = WebSocketMessage(event: event, data: data);
      _channel?.sink.add(json.encode(message.toJson()));
    }
  }

  void reconnect() {
    Future.delayed(Duration(seconds: 5), () {
      connect();
    });
  }

  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}
