import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/core/config/app_config.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';
import 'package:twizzle/features/messages/domain/repositories/message_repository.dart';
import 'package:twizzle/core/services/socket_service.dart';
import 'package:twizzle/features/messages/data/models/message_model.dart';
import 'package:twizzle/injection_container.dart';
import 'package:twizzle/core/services/call_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository repository;
  final SocketService socketService;

  MessageProvider({required this.repository, required this.socketService});

  List<Conversation> _conversations = [];
  List<ChatMessage> _chatMessages = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String _error = '';
  bool _isSocketInitialized = false;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get chatMessages => _chatMessages;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String get error => _error;

  void initSocket(String userId) {
    if (_isSocketInitialized) return;
    _isSocketInitialized = true;
    
    socketService.connect(DioClient.getResolvedBaseUrl(), userId);
    
    socketService.messageStream.listen((data) {
      if (data != null) {
        final newMessage = ChatMessageModel.fromJson(data);
        if (_chatMessages.isNotEmpty && _chatMessages.first.conversationId == newMessage.conversationId) {
          if (!_chatMessages.any((m) => m.id == newMessage.id)) {
             _chatMessages.insert(0, newMessage);
             notifyListeners();
          }
        }
        loadConversations();
      }
    });

    socketService.deleteStream.listen((data) {
      final messageId = data['messageId'];
      final type = data['type'];
      final deletedByUserId = data['userId'];
      final conversationId = data['conversationId'];

      if (type == 'everyone') {
        final index = _chatMessages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final oldMsg = _chatMessages[index];
          _chatMessages[index] = ChatMessage(
            id: oldMsg.id,
            conversationId: oldMsg.conversationId,
            senderId: oldMsg.senderId,
            content: 'This message was removed',
            createdAt: oldMsg.createdAt,
            isDeletedEveryone: true,
            type: 'text',
          );
          notifyListeners();
        }
      } else if (type == 'me' && deletedByUserId == socketService.userId) {
        _chatMessages.removeWhere((m) => m.id == messageId);
        notifyListeners();
      }
      loadConversations();
    });

    socketService.callStream.listen((data) {
       final event = data['event'];
       if (event == 'incomming:call') {
         _incomingCallController.add(data);
       } else if (event == 'call:accepted') {
          sl<CallService>().handleAnswer(data['ans']);
       } else if (event == 'peer:ice:candidate') {
          sl<CallService>().handleIceCandidate(data['candidate']);
       } else if (event == 'call:rejected') {
          sl<CallService>().hangUp();
       }
    });
  }

  final _incomingCallController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingCallStream => _incomingCallController.stream;

  @override
  void dispose() {
    _incomingCallController.close();
    super.dispose();
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await repository.getConversations();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (list) {
        _conversations = list;
        _isLoading = false;
        notifyListeners();
        getUnreadCount();
      },
    );
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.getMessages(conversationId);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (list) {
        _chatMessages = list;
        _isLoading = false;
        notifyListeners();
        repository.markAsRead(conversationId).then((_) => getUnreadCount());
      },
    );
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final result = await repository.sendMessage(conversationId, content);
    result.fold(
      (failure) => null,
      (msg) {
        if (!_chatMessages.any((m) => m.id == msg.id)) {
          _chatMessages.insert(0, msg);
          notifyListeners();
        }
      },
    );
  }

  Future<void> sendImageMessage(String conversationId, String filePath) async {
    final result = await repository.sendImageMessage(conversationId, filePath);
    result.fold(
      (failure) => null,
      (msg) {
        if (!_chatMessages.any((m) => m.id == msg.id)) {
          _chatMessages.insert(0, msg);
          notifyListeners();
        }
      },
    );
  }
  
  // Also updating the socket listener prefix check for safety
  void _attachSocketListeners(String userId) {
    // ... logic already inside initSocket ...
  }

  Future<void> getUnreadCount() async {
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => null,
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  Future<Conversation?> getOrCreateConversation(String targetUserId) async {
    // Check if conversation already exists in local list
    for (final conv in _conversations) {
       if (conv.participantId == targetUserId || conv.participantUsername == targetUserId) {
         return conv;
       }
    }
    
    _isLoading = true;
    notifyListeners();

    final result = await repository.startConversation(targetUserId);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (conversation) {
        // Add to list if not there
        if (!_conversations.any((c) => c.id == conversation.id)) {
          _conversations.insert(0, conversation);
        }
        _isLoading = false;
        notifyListeners();
        return conversation;
      },
    );
  }

  Future<void> deleteMessage(String messageId, String type) async {
    final result = await repository.deleteMessage(messageId, type);
    result.fold(
      (failure) => null, // Handle error if needed
      (_) {
        if (type == 'me') {
          _chatMessages.removeWhere((m) => m.id == messageId);
        } else {
          final index = _chatMessages.indexWhere((m) => m.id == messageId);
          if (index != -1) {
            final oldMsg = _chatMessages[index];
            _chatMessages[index] = ChatMessage(
              id: oldMsg.id,
              conversationId: oldMsg.conversationId,
              senderId: oldMsg.senderId,
              content: 'This message was removed',
              createdAt: oldMsg.createdAt,
              isDeletedEveryone: true,
              type: 'text',
            );
          }
        }
        notifyListeners();
        loadConversations();
      },
    );
  }
}
