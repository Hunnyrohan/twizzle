import '../../domain/entities/notification.dart';

class NotificationModel extends UserNotification {
  NotificationModel({
    required super.id,
    required super.type,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.authorUsername,
    required super.authorAvatar,
    super.authorIsVerified = false,
    super.tweetId,
    required super.createdAt,
    super.isRead = false,
    super.postPreviewContent,
    super.postPreviewImage,
    super.commentText,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>? ?? {};
    final type = json['type'] as String? ?? 'like';
    
    // Generate content based on type if backend doesn't provide a message
    String content = json['message'] as String? ?? json['content'] as String? ?? '';
    if (content.isEmpty) {
      switch (type) {
        case 'like': content = 'liked your post'; break;
        case 'follow': content = 'followed you'; break;
        case 'mention': content = 'mentioned you'; break;
        case 'comment': content = 'replied to your post'; break;
        case 'repost': content = 'reposted your post'; break;
        case 'bookmark': content = 'bookmarked your post'; break;
        default: content = 'interacted with your profile';
      }
    }

    final postPreview = json['postPreview'] as Map<String, dynamic>?;
    final tweetId = postPreview != null ? postPreview['_id'] as String? : (json['tweetId'] as String? ?? json['postId'] as String?);

    return NotificationModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      type: type,
      content: content,
      authorId: actor['_id'] as String? ?? actor['id'] as String? ?? '',
      authorName: actor['name'] as String? ?? 'User',
      authorUsername: actor['username'] as String? ?? 'user',
      authorAvatar: actor['image'] as String? ?? actor['avatar'] as String? ?? '',
      authorIsVerified: actor['isVerified'] as bool? ?? false,
      tweetId: tweetId,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      postPreviewContent: postPreview?['content'] as String?,
      postPreviewImage: postPreview?['image'] as String?,
      commentText: json['commentText'] as String?,
    );
  }
}
