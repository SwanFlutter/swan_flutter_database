import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class RealtimeEvent {
  final String event;
  final dynamic data;
  final String? room;

  RealtimeEvent({
    required this.event,
    this.data,
    this.room,
  });
}

class RealtimeService {
  late IO.Socket _socket;
  final String baseUrl;
  final String? token;
  final _eventController = StreamController<RealtimeEvent>.broadcast();

  RealtimeService(this.baseUrl, {this.token}) {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    // اتصال به سوکت
    _socket.connect();

    // مدیریت رویدادهای پایه
    _socket.onConnect((_) {
      print('Socket Connected');
      _eventController.add(RealtimeEvent(event: 'connected'));
    });

    _socket.onDisconnect((_) {
      print('Socket Disconnected');
      _eventController.add(RealtimeEvent(event: 'disconnected'));
    });

    _socket.onError((error) {
      print('Socket Error: $error');
      _eventController.add(RealtimeEvent(event: 'error', data: error));
    });
  }

  // گوش دادن به یک رویداد خاص
  void on(String event, Function(dynamic) callback) {
    _socket.on(event, (data) {
      callback(data);
      _eventController.add(RealtimeEvent(event: event, data: data));
    });
  }

  // ارسال رویداد
  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  // پیوستن به یک اتاق
  void joinRoom(String room) {
    _socket.emit('join_room', room);
  }

  // ترک یک اتاق
  void leaveRoom(String room) {
    _socket.emit('leave_room', room);
  }

  // ارسال پیام به یک اتاق خاص
  void emitToRoom(String room, String event, dynamic data) {
    _socket.emit('room_message', {
      'room': room,
      'event': event,
      'data': data,
    });
  }

  // دریافت همه رویدادها
  Stream<RealtimeEvent> get events => _eventController.stream;

  void dispose() {
    _socket.disconnect();
    _eventController.close();
  }
}
