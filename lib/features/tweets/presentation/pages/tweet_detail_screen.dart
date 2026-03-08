import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/tweets/presentation/widgets/reply_composer.dart';
import 'package:intl/intl.dart';

class TweetDetailScreen extends StatefulWidget {
  final String tweetId;

  const TweetDetailScreen({Key? key, required this.tweetId}) : super(key: key);

  @override
  State<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  Tweet? _tweet;
  List<Tweet> _comments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<TweetProvider>();
    
    final detailResult = await provider.getTweetDetails(widget.tweetId);
    detailResult.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (tweet) async {
        setState(() {
          _tweet = tweet;
        });
        
        final commentsResult = await provider.fetchComments(widget.tweetId);
        commentsResult.fold(
          (failure) => setState(() {
            _isLoading = false;
          }),
          (comments) => setState(() {
            _comments = comments;
            _isLoading = false;
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TweetProvider>(
      builder: (context, provider, child) {
        // Source of truth: cache
        final tweet = provider.cache[widget.tweetId] ?? _tweet;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            centerTitle: true,
          ),
          body: _isLoading && tweet == null
              ? const Center(child: CircularProgressIndicator())
              : _error != null && tweet == null
                  ? Center(child: Text(_error!))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        children: [
                          if (tweet != null) ...[
                            _buildMainTweet(tweet),
                            const Divider(height: 1),
                            _buildCommentsList(provider),
                          ],
                        ],
                      ),
                    ),
          bottomNavigationBar: tweet != null ? _buildReplyInput() : null,
        );
      },
    );
  }

  Widget _buildMainTweet(Tweet tweet) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: tweet.authorAvatar.isNotEmpty
                    ? NetworkImage(MediaUtils.resolveImageUrl(tweet.authorAvatar))
                    : null,
                child: tweet.authorAvatar.isEmpty
                    ? Text(tweet.authorName[0])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tweet.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (tweet.authorIsVerified) ...[
                          const SizedBox(width: 4),
                          const VerifiedBadge(size: 16),
                        ],
                      ],
                    ),
                    Text(
                      '@${tweet.authorUsername}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tweet.content,
            style: const TextStyle(fontSize: 20, height: 1.3),
          ),
          if (tweet.media.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomImage(
                imageUrl: MediaUtils.resolveImageUrl(tweet.media.first),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            DateFormat('h:mm a · MMM d, y').format(tweet.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildCount(tweet.retweetsCount, 'Reposts'),
                const SizedBox(width: 20),
                _buildCount(tweet.likesCount, 'Likes'),
                const SizedBox(width: 20),
                _buildCount(tweet.repliesCount, 'Replies'),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActionButtons(tweet),
        ],
      ),
    );
  }

  Widget _buildCount(int count, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: '$count ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Tweet tweet) {
    final provider = context.read<TweetProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 22, color: Colors.grey),
            onPressed: () => _openReplyComposer(),
          ),
          IconButton(
            icon: Icon(
              Icons.repeat, 
              size: 22, 
              color: tweet.isRetweeted ? Colors.green : Colors.grey
            ),
            onPressed: () => provider.toggleRetweet(tweet.id),
          ),
          IconButton(
            icon: Icon(
              tweet.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 22,
              color: tweet.isLiked ? Colors.red : Colors.grey,
            ),
            onPressed: () => provider.toggleLike(tweet.id),
          ),
          IconButton(
            icon: Icon(
              tweet.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 22,
              color: tweet.isBookmarked ? Colors.blue : Colors.grey,
            ),
            onPressed: () => provider.toggleBookmark(tweet.id),
          ),
          const IconButton(
            icon: Icon(Icons.share_outlined, size: 22, color: Colors.grey),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(TweetProvider provider) {
    if (_comments.isEmpty && !_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No replies yet', style: TextStyle(color: Colors.grey))),
      );
    }
    
    return Column(
      children: _comments.map((comment) {
        // Pull latest version of this comment from cache for perfect reactivity
        final reactiveComment = provider.cache[comment.id] ?? comment;
        return TweetCard(
          tweet: reactiveComment,
          onAction: _loadData,
        );
      }).toList(),
    );
  }

  Widget _buildReplyInput() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        top: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: InkWell(
        onTap: _openReplyComposer,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text('Post your reply', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  void _openReplyComposer() {
    if (_tweet == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReplyComposer(
        parentTweet: _tweet!,
      ),
    ).then((_) => _loadData());
  }
}
