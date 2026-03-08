import '../../domain/entities/tweet.dart';

class TweetModel extends Tweet {
  TweetModel({
    required super.id,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.authorUsername,
    required super.authorAvatar,
    super.authorIsVerified = false,
    required super.media,
    required super.likesCount,
    required super.retweetsCount,
    required super.repliesCount,
    required super.createdAt,
    super.isLiked = false,
    super.isRetweeted = false,
    super.isBookmarked = false,
    super.retweetOf,
    super.location,
  });

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for author
    final authorRaw = json['author'];
    final Map<String, dynamic> author = (authorRaw is Map<String, dynamic>) ? authorRaw : {};
    final String authorIdFromRaw = (authorRaw is String) ? authorRaw : (author['_id'] ?? author['id'] ?? '');

    // Defensive parsing for retweetOf
    final retweetOfRaw = json['retweetOf'];
    final Map<String, dynamic>? retweetOfMap = (retweetOfRaw is Map<String, dynamic>) ? retweetOfRaw : null;
    
    return TweetModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: authorIdFromRaw,
      authorName: author['name'] as String? ?? author['displayName'] as String? ?? '',
      authorUsername: author['username'] as String? ?? '',
      authorAvatar: author['image'] as String? ?? 
                    author['avatar'] as String? ?? 
                    author['avatarUrl'] as String? ?? '',
      authorIsVerified: author['isVerified'] as bool? ?? author['verified'] as bool? ?? false,
      media: (json['media'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likesCount: json['likesCount'] as int? ?? 0,
      retweetsCount: json['retweetsCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      isLiked: json['isLiked'] as bool? ?? false,
      isRetweeted: json['isRetweeted'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      retweetOf: retweetOfMap != null ? TweetModel.fromJson(retweetOfMap) : null,
      location: json['location'] as String?,
    );
  }

  TweetModel copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    bool? authorIsVerified,
    List<String>? media,
    int? likesCount,
    int? retweetsCount,
    int? repliesCount,
    DateTime? createdAt,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
    Tweet? retweetOf,
    String? location,
  }) {
    return TweetModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      retweetsCount: retweetsCount ?? this.retweetsCount,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      retweetOf: retweetOf ?? this.retweetOf,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': {
        'id': authorId,
        'name': authorName,
        'username': authorUsername,
        'avatar': authorAvatar,
        'isVerified': authorIsVerified,
      },
      'media': media,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'isBookmarked': isBookmarked,
      'retweetOf': retweetOf != null ? (retweetOf as TweetModel).toJson() : null,
      'location': location,
    };
  }
}
