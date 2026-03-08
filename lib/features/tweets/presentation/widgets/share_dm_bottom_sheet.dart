import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/features/search/presentation/providers/search_provider.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/verified_badge.dart';

class ShareDmBottomSheet extends StatefulWidget {
  final String tweetUrl;

  const ShareDmBottomSheet({Key? key, required this.tweetUrl}) : super(key: key);

  @override
  State<ShareDmBottomSheet> createState() => _ShareDmBottomSheetState();
}

class _ShareDmBottomSheetState extends State<ShareDmBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSending = false;
  String? _sendingToId;

  @override
  void initState() {
    super.initState();
    // Load conversations on init
    Future.microtask(() => context.read<MessageProvider>().loadConversations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageProvider = context.watch<MessageProvider>();
    final searchProvider = context.watch<SearchProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Send post',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
                if (val.length >= 2) {
                  searchProvider.performSearch(val);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search people',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recipients List
          Expanded(
            child: _searchQuery.length >= 2
                ? _buildSearchResults(searchProvider)
                : _buildRecentConversations(messageProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = provider.results.whereType<User>().toList();

    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => _RecipientTile(
        user: users[index],
        isSending: _isSending && _sendingToId == users[index].id,
        onSend: () => _handleSend(users[index].id),
      ),
    );
  }

  Widget _buildRecentConversations(MessageProvider provider) {
    if (provider.isLoading && provider.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final convs = provider.conversations;

    if (convs.isEmpty) {
      return const Center(child: Text('No recent conversations'));
    }

    return ListView.builder(
      itemCount: convs.length,
      itemBuilder: (context, index) {
        final conv = convs[index];
        return _RecipientTile(
          participantName: conv.participantName,
          participantUsername: conv.participantUsername,
          participantAvatar: conv.participantAvatar,
          isVerified: conv.participantIsVerified,
          isSending: _isSending && _sendingToId == conv.participantId,
          onSend: () => _handleSend(conv.participantId),
        );
      },
    );
  }

  Future<void> _handleSend(String userId) async {
    setState(() {
      _isSending = true;
      _sendingToId = userId;
    });

    try {
      final messageProvider = context.read<MessageProvider>();
      final conversation = await messageProvider.getOrCreateConversation(userId);
      
      if (conversation != null) {
        await messageProvider.sendMessage(
          conversation.id, 
          'Check out this post: ${widget.tweetUrl}',
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post sent!')),
          );
        }
      } else {
        throw Exception('Could not start conversation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingToId = null;
        });
      }
    }
  }
}

class _RecipientTile extends StatelessWidget {
  final User? user;
  final String? participantName;
  final String? participantUsername;
  final String? participantAvatar;
  final bool isVerified;
  final bool isSending;
  final VoidCallback onSend;

  const _RecipientTile({
    Key? key,
    this.user,
    this.participantName,
    this.participantUsername,
    this.participantAvatar,
    this.isVerified = false,
    required this.isSending,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? participantName ?? 'Unknown';
    final username = user?.username ?? participantUsername ?? 'user';
    final avatar = user?.image ?? participantAvatar;
    final verified = user?.isVerified ?? isVerified;

    return ListTile(
      leading: ClipOval(
        child: avatar != null
            ? CustomImage(
                imageUrl: MediaUtils.resolveImageUrl(avatar),
                width: 40,
                height: 40,
              )
            : const CircleAvatar(radius: 20, child: Icon(Icons.person)),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (verified) ...[
            const SizedBox(width: 4),
            const VerifiedBadge(size: 14),
          ],
        ],
      ),
      subtitle: Text('@$username'),
      trailing: isSending
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.send_rounded, color: Color(0xff1DA1F2)),
              onPressed: onSend,
            ),
    );
  }
}
