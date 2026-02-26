class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantUsername;
  final String participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool participantIsVerified;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantUsername,
    required this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.participantIsVerified = false,
  });
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String type; // 'text', 'image', 'call'
  final String? mediaUrl;
  final Map<String, dynamic>? callData;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.type = 'text',
    this.mediaUrl,
    this.callData,
  });
}
