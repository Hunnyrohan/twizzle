enum NotificationType { like, retweet, follow, comment, message, trend }

class UserNotification {
  final String id;
  final String type;
  final String content;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final bool authorIsVerified;
  final String? tweetId;
  final DateTime createdAt;
  final bool isRead;
  
  // Rich preview fields
  final String? postPreviewContent;
  final String? postPreviewImage;
  final String? commentText;

  UserNotification({
    required this.id,
    required this.type,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    this.authorIsVerified = false,
    this.tweetId,
    required this.createdAt,
    this.isRead = false,
    this.postPreviewContent,
    this.postPreviewImage,
    this.commentText,
  });

}
