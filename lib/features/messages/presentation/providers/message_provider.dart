import 'dart:async';
import 'package:flutter/material.dart';
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

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get chatMessages => _chatMessages;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String get error => _error;

  void initSocket(String userId) {
    socketService.connect('http://10.0.2.2:5000', userId);
    
    socketService.messageStream.listen((data) {
      if (data != null) {
        final newMessage = ChatMessageModel.fromJson(data);
        // Only add if it's for the current conversation being viewed
        // In a more complex app, we'd handle background updates for other conversations too
        if (_chatMessages.isNotEmpty && _chatMessages.first.conversationId == newMessage.conversationId) {
          if (!_chatMessages.any((m) => m.id == newMessage.id)) {
             _chatMessages.insert(0, newMessage);
             notifyListeners();
          }
        }
        
        // Update unread count in the conversation list
        final index = _conversations.indexWhere((c) => c.id == newMessage.conversationId);
        if (index != -1) {
           loadConversations(); // Simplest way to refresh the list state
        }
      }
    });

    socketService.callStream.listen((data) {
       final event = data['event'];
       if (event == 'incomming:call') {
         _incomingCallController.add(data);
       } else if (event == 'call:accepted') {
          sl<CallService>().handleAnswer(data['ans']);
       } else if (event == 'peer:ice:candidate') {
          sl<CallService>().handleIceCandidate(data['candidate']);
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
        repository.markAsRead(conversationId);
      },
    );
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final result = await repository.sendMessage(conversationId, content);
    result.fold(
      (failure) => null,
      (msg) {
        _chatMessages.insert(0, msg); // Insert at 0 because of reverse list
        notifyListeners();
      },
    );
  }

  Future<void> sendImageMessage(String conversationId, String filePath) async {
    final result = await repository.sendImageMessage(conversationId, filePath);
    result.fold(
      (failure) => null,
      (msg) {
        _chatMessages.insert(0, msg);
        notifyListeners();
      },
    );
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
    final existing = _conversations.firstWhere(
      (c) => c.id == targetUserId || c.participantUsername == targetUserId, // Simple check if targetUserId happens to be a username or id match
      orElse: () => Conversation(id: '', participantId: '', participantName: '', participantUsername: '', participantAvatar: '', lastMessage: '', lastMessageTime: DateTime.now()),
    );
    
    // In reality, we should check by participant ID. Since Conversation entity doesn't have participantId, we rely on the backend to handle it.
    
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
}
