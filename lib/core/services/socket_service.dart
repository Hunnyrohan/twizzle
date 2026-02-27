import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketService {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _callController = StreamController<Map<String, dynamic>>.broadcast();
  final _deleteController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
 
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<Map<String, dynamic>> get deleteStream => _deleteController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
 
  bool get isConnected => _socket?.connected ?? false;
 
  String? _userId;
  String? get userId => _userId;
 
  void connect(String url, String userId) {
    // ... logic remains same ...
    if (_socket != null && _userId == userId && isConnected) return;

    if (_socket != null) {
      print('SocketService: Disconnecting old socket for user change/reconnect');
      disconnect();
    }

    _userId = userId;
    print('Connecting to socket: $url for user: $userId');
    _socket = io.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.connect();

    _socket?.onConnect((_) {
      print('Socket connected: ${_socket?.id}');
      _socket?.emit('join', _userId);
      _connectionController.add(true);
    });

    _socket?.on('reconnect', (_) {
      print('Socket reconnected, re-joining as $_userId');
      _socket?.emit('join', _userId);
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
      _connectionController.add(false);
    });

    // Messaging
    _socket?.on('new_message', (data) {
      print('New message received: $data');
      _messageController.add(data);
    });

    _socket?.on('message_deleted', (data) {
      print('Message deleted event: $data');
      _deleteController.add(data);
    });

    // Calling Signaling
    _socket?.on('incomming:call', (data) {
      print('Incoming call received: $data');
      _callController.add({'event': 'incomming:call', ...data});
    });

    _socket?.on('call:accepted', (data) {
      print('Call accepted: $data');
      _callController.add({'event': 'call:accepted', ...data});
    });

    _socket?.on('call:rejected', (data) {
      print('Call rejected: $data');
      _callController.add({'event': 'call:rejected', ...data});
    });

    _socket?.on('peer:ice:candidate', (data) {
      print('ICE candidate received: $data');
      _callController.add({'event': 'peer:ice:candidate', ...data});
    });

    _socket?.on('peer:nego:needed', (data) {
       _callController.add({'event': 'peer:nego:needed', ...data});
    });

     _socket?.on('peer:nego:final', (data) {
       _callController.add({'event': 'peer:nego:final', ...data});
    });
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _callController.close();
    _deleteController.close();
    _connectionController.close();
  }
}
