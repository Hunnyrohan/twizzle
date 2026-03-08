import 'package:flutter/material.dart';
import '../../../../widgets/verified_badge.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/core/utils/media_utils.dart';

class ReplyComposer extends StatefulWidget {
  final Tweet parentTweet;

  const ReplyComposer({Key? key, required this.parentTweet}) : super(key: key);

  @override
  State<ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<ReplyComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user;
    final tweet = widget.parentTweet;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
                ElevatedButton(
                  onPressed: _controller.text.trim().isNotEmpty && !_isPosting
                      ? () => _handleReply()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1DA1F2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xff1DA1F2).withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Reply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent Tweet Info (Small context)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ClipOval(
                          child: tweet.authorAvatar != null
                              ? CustomImage(
                                  imageUrl: MediaUtils.resolveImageUrl(tweet.authorAvatar!),
                                  width: 34,
                                  height: 34,
                                )
                              : const CircleAvatar(radius: 17, child: Icon(Icons.person, size: 18)),
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: tweet.authorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (tweet.authorIsVerified) ...[
                                  const WidgetSpan(child: SizedBox(width: 4)),
                                  WidgetSpan(child: VerifiedBadge(size: 14)),
                                ],
                                TextSpan(
                                  text: ' @${tweet.authorUsername}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tweet.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15),
                          ),
                          if (tweet.media.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: CustomImage(
                                  imageUrl: MediaUtils.resolveImageUrl(tweet.media[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                const TextSpan(text: 'Replying to '),
                                TextSpan(
                                  text: '@${tweet.authorUsername}',
                                  style: const TextStyle(color: Color(0xff1DA1F2)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reply Input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10), // Alignment with parent avatar
                    ClipOval(
                      child: user?.image != null
                          ? CustomImage(
                              imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                              width: 40,
                              height: 40,
                            )
                          : const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        autofocus: true,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "Post your reply",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toolbar (Optional characters count)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _controller.text.length > 280 ? Colors.red.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${280 - _controller.text.length}',
                    style: TextStyle(
                      color: _controller.text.length > 250 
                          ? Colors.red 
                          : _controller.text.isEmpty ? Colors.transparent : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _handleReply() async {
    setState(() => _isPosting = true);
    
    try {
      final success = await context.read<TweetProvider>().addComment(
        widget.parentTweet.id,
        _controller.text.trim(),
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply posted!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post reply. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
