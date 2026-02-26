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
    if (json.containsKey('otherUser')) {
      participant = Map<String, dynamic>.from(json['otherUser'] as Map);
    } else {
      final participants = (json['participants'] ?? json['participantIds'] as List? ?? []);
      final found = participants.firstWhere(
        (p) => (p['_id'] ?? p['id'])?.toString() != currentUserId,
        orElse: () => participants.isNotEmpty ? participants.first : {},
      );
      participant = Map<String, dynamic>.from(found as Map);
    }

    final lastMsg = json['lastMessage'] ?? json['lastMessageId'];
    final lastMsgText = lastMsg != null ? (lastMsg is Map ? (lastMsg['content'] ?? lastMsg['text'] ?? '') : lastMsg.toString()) : '';

    return ConversationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      participantId: (participant['_id'] ?? participant['id'] ?? '').toString(),
      participantName: participant['name'] as String? ?? 'User',
      participantUsername: participant['username'] as String? ?? 'user',
      participantAvatar: participant['image'] as String? ?? participant['avatar'] as String? ?? '',
      lastMessage: lastMsgText,
      lastMessageTime: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
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
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Backend uses 'text' for content
    final content = json['text'] as String? ?? json['content'] as String? ?? '';
    
    // Backend uses 'conversationId' and 'senderId'
    final conversationId = (json['conversationId'] ?? json['conversation'] ?? '').toString();
    
    String senderId = '';
    if (json.containsKey('senderId')) {
      senderId = json['senderId'].toString();
    } else if (json['sender'] != null) {
      if (json['sender'] is Map) {
        senderId = (json['sender']['_id'] ?? json['sender']['id'] ?? '').toString();
      } else {
        senderId = json['sender'].toString();
      }
    }

    // Call data parsing
    Map<String, dynamic>? callData;
    if (json['callData'] != null && json['callData'] is Map) {
      callData = Map<String, dynamic>.from(json['callData'] as Map);
    }

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? (json['status'] == 'seen'),
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      callData: callData,
    );
  }
}
