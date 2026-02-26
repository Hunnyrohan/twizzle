import 'package:flutter/material.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/widgets/custom_image.dart';

class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onAction;

  const TweetCard({Key? key, required this.tweet, required this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TweetProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context, 
                  '/profile',
                  arguments: tweet.authorUsername,
                ),
                child: ClipOval(
                  child: tweet.authorAvatar.isNotEmpty
                      ? CustomImage(
                          imageUrl: MediaUtils.resolveImageUrl(tweet.authorAvatar),
                          width: 50,
                          height: 50,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Theme.of(context).dividerColor,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context, 
                              '/profile',
                              arguments: tweet.authorUsername,
                            ),
                            child: Text(
                              tweet.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (tweet.authorIsVerified) ...[
                          const SizedBox(width: 4),
                          const VerifiedBadge(size: 15),
                        ],
                        const SizedBox(width: 4),
                        Text(
                          '@${tweet.authorUsername} · ${_formatDate(tweet.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tweet.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    // Main Media
                    if (tweet.media.isNotEmpty) _buildMedia(context, tweet.media),
                    
                    // Retweeted Content
                    if (tweet.retweetOf != null) ...[
                      const SizedBox(height: 12),
                      _buildRetweetedContent(context, tweet.retweetOf!),
                    ],

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _interactionIcon(
                          Icons.chat_bubble_outline_rounded,
                          tweet.repliesCount,
                          const Color(0xff1d9bf0),
                          onTap: () => _showCommentDialog(context, provider),
                        ),
                        _interactionIcon(
                          Icons.repeat_rounded,
                          tweet.retweetsCount,
                          const Color(0xff00ba7c),
                          active: tweet.isRetweeted,
                          onTap: () => provider.toggleRetweet(tweet.id),
                        ),
                        _interactionIcon(
                          tweet.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          tweet.likesCount,
                          const Color(0xfff91880),
                          active: tweet.isLiked,
                          onTap: () => provider.toggleLike(tweet.id),
                        ),
                        _interactionIcon(
                          tweet.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          0,
                          const Color(0xff1d9bf0),
                          active: tweet.isBookmarked,
                          onTap: () => provider.toggleBookmark(tweet.id),
                        ),
                        _interactionIcon(Icons.share_outlined, 0, const Color(0xff1d9bf0)),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  Widget _buildMedia(BuildContext context, List<String> media) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400),
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          child: CustomImage(
            imageUrl: MediaUtils.resolveImageUrl(media.first),
            fit: BoxFit.cover,
            errorWidget: Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetweetedContent(BuildContext context, Tweet original) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).dividerColor.withOpacity(0.02),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: original.authorAvatar.isNotEmpty
                    ? CustomImage(
                        imageUrl: MediaUtils.resolveImageUrl(original.authorAvatar),
                        width: 24,
                        height: 24,
                      )
                    : Container(
                        width: 24,
                        height: 24,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 14, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  original.authorName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (original.authorIsVerified) ...[
                const SizedBox(width: 4),
                const VerifiedBadge(size: 14),
              ],
              const SizedBox(width: 4),
              Text(
                '@${original.authorUsername}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            original.content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          if (original.media.isNotEmpty) _buildMedia(context, original.media),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, TweetProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Post your reply'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final success = await provider.addComment(tweet.id, controller.text.trim());
                if (success && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  Widget _interactionIcon(IconData icon, int count, Color activeColor,
      {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? activeColor.withOpacity(0.1) : Colors.transparent,
              ),
              child: Icon(
                icon, 
                size: 18, 
                color: active ? activeColor : Colors.grey.shade600
              ),
            ),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: active ? activeColor : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(date);
  }
}
