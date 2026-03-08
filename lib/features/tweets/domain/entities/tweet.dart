import 'package:equatable/equatable.dart';

class Tweet extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final bool authorIsVerified;
  final List<String> media;
  final int likesCount;
  final int retweetsCount;
  final int repliesCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;
  final Tweet? retweetOf;
  final String? location; // Sensor 2: GPS Location

  Tweet({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    this.authorIsVerified = false,
    required this.media,
    required this.likesCount,
    required this.retweetsCount,
    required this.repliesCount,
    required this.createdAt,
    this.isLiked = false,
    this.isRetweeted = false,
    this.isBookmarked = false,
    this.retweetOf,
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorName,
        authorUsername,
        authorAvatar,
        authorIsVerified,
        media,
        likesCount,
        retweetsCount,
        repliesCount,
        createdAt,
        isLiked,
        isRetweeted,
        isBookmarked,
        retweetOf,
        location,
      ];
}
