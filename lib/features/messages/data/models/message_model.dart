import '../../domain/entities/message.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    required super.participantUsername,
    required super.participantAvatar,
    required super.lastMessage,
    required super.lastMessageTime,
    super.unreadCount = 0,
    super.participantIsVerified = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Backend enriched format has 'otherUser'
    Map<String, dynamic> participant = {};
    
    if (json['otherUser'] != null) {
      participant = Map<String, dynamic>.from(json['otherUser'] as Map);
    } else if (json['participantIds'] != null && (json['participantIds'] as List).isNotEmpty) {
      final participants = json['participantIds'] as List;
      final found = participants.firstWhere(
        (p) => (p is Map) && (p['_id'] ?? p['id'])?.toString() != currentUserId,
        orElse: () => participants.firstWhere((p) => p is Map, orElse: () => {}),
      );
      if (found is Map) {
        participant = Map<String, dynamic>.from(found);
      }
    } else if (json['participants'] != null && (json['participants'] as List).isNotEmpty) {
      final participants = json['participants'] as List;
      final found = participants.firstWhere(
        (p) => (p is Map) && (p['_id'] ?? p['id'])?.toString() != currentUserId,
        orElse: () => participants.firstWhere((p) => p is Map, orElse: () => {}),
      );
      if (found is Map) {
        participant = Map<String, dynamic>.from(found);
      }
    }

    final lastMsg = json['lastMessage'] ?? json['lastMessageId'];
    String lastMsgText = '';
    DateTime lastTime = DateTime.now();
    
    try {
      if (json['updatedAt'] != null) {
        lastTime = DateTime.parse(json['updatedAt'] as String);
      }
    } catch (_) {}

    if (lastMsg != null && lastMsg is Map) {
      final type = lastMsg['type'] ?? 'text';
      if (type == 'call') {
        final callData = lastMsg['callData'] ?? {};
        final callType = callData['type'] ?? 'voice';
        lastMsgText = '${callType.toString().toUpperCase().substring(0, 1)}${callType.toString().substring(1)} call';
      } else if (type == 'image') {
        lastMsgText = 'Sent an image';
      } else {
        lastMsgText = lastMsg['text'] ?? lastMsg['content'] ?? '';
      }
      
      try {
        if (lastMsg['createdAt'] != null) {
          lastTime = DateTime.parse(lastMsg['createdAt'] as String);
        }
      } catch (_) {}
    } else if (lastMsg != null) {
      lastMsgText = lastMsg.toString();
    }

    return ConversationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      participantId: (participant['_id'] ?? participant['id'] ?? '').toString(),
      participantName: (participant['name'] ?? participant['displayName'] ?? 'User').toString(),
      participantUsername: (participant['username'] ?? 'user').toString(),
      participantAvatar: (participant['image'] ?? participant['avatar'] ?? participant['profilePic'] ?? '').toString(),
      lastMessage: lastMsgText,
      lastMessageTime: lastTime.toLocal(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      participantIsVerified: participant['isVerified'] as bool? ?? participant['verified'] as bool? ?? false,
    );
  }
}

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.isRead = false,
    super.type = 'text',
    super.mediaUrl,
    super.callData,
    super.isDeletedEveryone = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Backend uses 'text' or 'content' for content
    final content = (json['text'] ?? json['content'] ?? '').toString();
    
    // Backend uses 'conversationId' or 'conversation'
    final conversationId = (json['conversationId'] ?? json['conversation'] ?? '').toString();
    
    String senderId = '';
    if (json['senderId'] != null) {
      if (json['senderId'] is Map) {
        senderId = (json['senderId']['_id'] ?? json['senderId']['id'] ?? '').toString();
      } else {
        senderId = json['senderId'].toString();
      }
    } else if (json['sender'] != null) {
      final sender = json['sender'];
      if (sender is Map) {
        senderId = (sender['_id'] ?? sender['id'] ?? '').toString();
      } else {
        senderId = sender.toString();
      }
    }

    // Call data parsing
    Map<String, dynamic>? callData;
    if (json['callData'] != null && json['callData'] is Map) {
      callData = Map<String, dynamic>.from(json['callData'] as Map);
    }

    final type = (json['type'] ?? 'text').toString();
    String? mediaUrl = json['mediaUrl']?.toString();
    
    // Support backend 'attachments' field
    if (json['attachments'] != null && json['attachments'] is List && (json['attachments'] as List).isNotEmpty) {
      mediaUrl = (json['attachments'] as List).first.toString();
    } else if (json['attachment'] != null) {
       mediaUrl = json['attachment'].toString();
    }

    DateTime createdAt = DateTime.now();
    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt'] as String);
      }
    } catch (_) {}

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      createdAt: createdAt.toLocal(),
      isRead: json['isRead'] as bool? ?? (json['status'] == 'seen'),
      type: type,
      mediaUrl: mediaUrl,
      callData: callData,
      isDeletedEveryone: json['isDeletedEveryone'] as bool? ?? false,
    );
  }
}
