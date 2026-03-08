import 'package:flutter/material.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:twizzle/features/tweets/presentation/widgets/share_dm_bottom_sheet.dart';
import 'package:twizzle/features/tweets/presentation/widgets/reply_composer.dart';

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
        InkWell(
          onTap: () {
            Navigator.pushNamed(
              context, 
              '/tweet-detail',
              arguments: tweet.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tweet.retweetOf != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Reposted',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
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
                                errorWidget: _buildAvatarFallback(context, tweet.authorName, tweet.authorUsername, 50),
                              )
                            : _buildAvatarFallback(context, tweet.authorName, tweet.authorUsername, 50),
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
                              Expanded(
                                child: Text(
                                  '@${tweet.authorUsername} · ${_formatDate(tweet.createdAt)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showOptions(context, provider),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tweet.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Main Media
                          if (tweet.media.isNotEmpty) _buildMedia(context, tweet.media),
                          
                          if (tweet.location != null && tweet.location!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  tweet.location!,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                          
                          // Retweeted Content
                          if (tweet.retweetOf != null) ...[
                            const SizedBox(height: 10),
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
                               _interactionIcon(
                                Icons.share_outlined, 
                                0, 
                                const Color(0xff1d9bf0),
                                onTap: () => _showShareOptions(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 0.5, thickness: 0.5),
      ],
    );
  }

  Widget _buildMedia(BuildContext context, List<String> media) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 450),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomImage(
            imageUrl: MediaUtils.resolveImageUrl(media.first),
            fit: BoxFit.cover,
            errorWidget: Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetweetedContent(BuildContext context, Tweet original) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
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
                        width: 20,
                        height: 20,
                        errorWidget: _buildAvatarFallback(context, original.authorName, original.authorUsername, 20),
                      )
                    : _buildAvatarFallback(context, original.authorName, original.authorUsername, 20),
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
              Expanded(
                child: Text(
                  '@${original.authorUsername}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            original.content,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
          if (original.media.isNotEmpty) ...[
            const SizedBox(height: 8),
             _buildMedia(context, original.media),
          ],
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    // In a real app, this would be your production URL
    final String tweetUrl = 'https://twizzle.app/tweet/${tweet.id}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Copy link to post'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: tweetUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.send_rounded),
              title: const Text('Send via Direct Message'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ShareDmBottomSheet(
                    tweetUrl: tweetUrl,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share post via...'),
              onTap: () async {
                Navigator.pop(context);
                await Share.share(
                  'Check out this post on Twizzle: $tweetUrl',
                  subject: 'Post by ${tweet.authorName}',
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, TweetProvider provider) {
    final userProvider = context.read<UserProvider>();
    final isOwner = userProvider.user?.id == tweet.authorId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Post', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showConfirmDialog(context, 'Delete Post', 'Are you sure you want to delete this post?');
                  if (confirmed == true) {
                    await provider.deleteTweet(tweet.id);
                  }
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.block_outlined, color: Colors.red),
                title: Text('Block @${tweet.authorUsername}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showConfirmDialog(context, 'Block @${tweet.authorUsername}', 'Are you sure you want to block this account?');
                  if (confirmed == true) {
                    await provider.toggleBlock(tweet.authorId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.sentiment_dissatisfied_outlined),
                title: const Text('Not interested'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<TweetProvider>().toggleNotInterested(tweet.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as not interested'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(title.split(' ')[0], style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, TweetProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReplyComposer(parentTweet: tweet),
    );
  }

  Widget _interactionIcon(IconData icon, int count, Color activeColor,
      {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? activeColor.withOpacity(0.08) : Colors.transparent,
              ),
              child: Icon(
                icon, 
                size: 18, 
                color: active ? activeColor : Colors.grey.shade600
              ),
            ),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 4),
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

  Widget _buildAvatarFallback(BuildContext context, String name, String username, double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xff1DA1F2),
      alignment: Alignment.center,
      child: Text(
        (name.isNotEmpty ? name : username)[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
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
