// lib/domain/entities/tweet.dart
class Tweet {
  final String id;
  final String name;
  final String handle;
  final String time;
  final String text;
  final String avatar;
  int likes;
  int retweets;
  int replies;

  Tweet({
    required this.id,
    required this.name,
    required this.handle,
    required this.time,
    required this.text,
    required this.avatar,
    required this.likes,
    required this.retweets,
    required this.replies,
  });
}