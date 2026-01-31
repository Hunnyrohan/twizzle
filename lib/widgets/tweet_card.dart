// lib/presentation/widgets/tweet_card.dart
import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/entities/tweet.dart';

class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onAction;

  const TweetCard({Key? key, required this.tweet, required this.onAction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: tablet ? 12 : 8, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: tablet ? 26 : 22,
              backgroundImage: NetworkImage(tweet.avatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tweet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '@${tweet.handle} · ${tweet.time}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tweet.text,
                    style: const TextStyle(fontFamily: 'OpenSans'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _iconButton(Icons.chat_bubble_outline, tweet.replies, () {
                        tweet.replies++;
                        onAction();
                      }),
                      const Spacer(),
                      _iconButton(Icons.repeat, tweet.retweets, () {
                        tweet.retweets++;
                        onAction();
                      }),
                      const Spacer(),
                      _iconButton(Icons.favorite_border, tweet.likes, () {
                        tweet.likes++;
                        onAction();
                      }),
                      const Spacer(),
                      const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, int count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
