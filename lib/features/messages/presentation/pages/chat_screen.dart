import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/messages/presentation/pages/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingImage = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MessageProvider>().loadMessages(widget.conversation.id);
    });
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null && mounted) {
      setState(() => _isSendingImage = true);
      await context.read<MessageProvider>().sendImageMessage(
        widget.conversation.id,
        image.path,
      );
      if (mounted) setState(() => _isSendingImage = false);
    }
  }

  void _initiateCall(bool video) {
    final currentUser = context.read<UserProvider>().user;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          targetUserId: widget.conversation.participantId,
          targetUserName: widget.conversation.participantName,
          targetUserAvatar: widget.conversation.participantAvatar,
          isVideo: video,
          // Pass caller's own info so the web app can display it correctly
          callerName: currentUser?.name,
          callerImage: currentUser?.image,
          callerIsVerified: currentUser?.isVerified ?? false,
          conversationId: widget.conversation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.id ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.conversation.participantUsername),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: widget.conversation.participantAvatar.isNotEmpty
                          ? NetworkImage(MediaUtils.resolveImageUrl(widget.conversation.participantAvatar))
                          : null,
                      child: widget.conversation.participantAvatar.isEmpty
                          ? Text(widget.conversation.participantName[0])
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.conversation.participantName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.conversation.participantIsVerified) ...[
                                const SizedBox(width: 4),
                                const VerifiedBadge(size: 14),
                              ],
                            ],
                          ),
                          Text(
                            '@${widget.conversation.participantUsername}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.call_outlined, size: 24),
                  onPressed: () => _initiateCall(false),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_outlined, size: 26),
                  onPressed: () => _initiateCall(true),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff15202b) : Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading && provider.chatMessages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                        bottom: 20,
                      ),
                      reverse: true,
                      itemCount: provider.chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = provider.chatMessages[index];
                        final isMe = message.senderId == userId;
                        return _buildMessageBubble(message, isMe, userId);
                      },
                    ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, String userId) {
    if (message.type == 'call') {
      return _buildCallMessage(message);
    }

    if (message.isDeletedEveryone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: const Text(
                'This message was removed',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final time = DateFormat('h:mm a').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onLongPress: () => _showDeleteMenu(message, isMe),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.conversation.participantUsername),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: widget.conversation.participantAvatar.isNotEmpty
                      ? NetworkImage(MediaUtils.resolveImageUrl(widget.conversation.participantAvatar))
                      : null,
                  child: widget.conversation.participantAvatar.isEmpty
                      ? Text(widget.conversation.participantName[0], style: const TextStyle(fontSize: 10))
                      : null,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: message.type == 'image' 
                        ? EdgeInsets.zero 
                        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMe && message.type != 'image'
                          ? const LinearGradient(
                              colors: [Color(0xff0084FF), Color(0xff007AFF)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                          : null,
                      color: isMe
                          ? (message.type == 'image' ? Colors.transparent : null)
                          : (message.type == 'image' ? Colors.transparent : (isDark ? const Color(0xff3E3E3E) : const Color(0xffE4E6EB))),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                    ),
                    child: message.type == 'image' && message.mediaUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Image.network(
                                MediaUtils.resolveImageUrl(message.mediaUrl!),
                                loadingBuilder: (_, child, loadingProgress) =>
                                    loadingProgress == null
                                        ? child
                                        : Container(
                                            width: 200,
                                            height: 150,
                                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                          ),
                                errorBuilder: (_, __, ___) => Container(
                                  width: 200, height: 150, 
                                  color: Colors.grey.shade800,
                                  child: const Icon(Icons.broken_image, color: Colors.white54),
                                ),
                              ),
                            ),
                          )
                        : message.type == 'image' && message.mediaUrl == null
                            ? const Icon(Icons.image_not_supported, color: Colors.white54)
                            : Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteMenu(ChatMessage message, bool isMe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Who do you want to remove this message for?'),
        content: const Text('This will permanently delete the message.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MessageProvider>().deleteMessage(message.id, 'me');
              Navigator.pop(context);
            },
            child: const Text('Remove for me'),
          ),
          if (isMe)
            TextButton(
              onPressed: () {
                context.read<MessageProvider>().deleteMessage(message.id, 'everyone');
                Navigator.pop(context);
              },
              child: const Text('Unsend for everyone', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildCallMessage(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final time = DateFormat('h:mm a').format(message.createdAt);
    final callData = message.callData ?? {};
    final type = callData['type'] ?? 'voice';
    final status = callData['status'] ?? 'ended';

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff273340).withOpacity(0.5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == 'video' ? Icons.videocam_outlined : Icons.call_outlined,
              size: 16,
              color: const Color(0xff1DA1F2),
            ),
            const SizedBox(width: 8),
            Text(
              '${type == 'video' ? 'Video' : 'Voice'} call $status',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff15202b) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: _isSendingImage 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.image_outlined, color: Color(0xff1DA1F2)),
            onPressed: _isSendingImage ? null : _pickImage,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Start a message',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xff1DA1F2),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (_msgController.text.trim().isNotEmpty) {
                  context.read<MessageProvider>().sendMessage(
                      widget.conversation.id, _msgController.text.trim());
                  _msgController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LinearRouteGradient extends LinearGradient {
  const LinearRouteGradient({
    required super.colors,
    super.begin = Alignment.centerLeft,
    super.end = Alignment.centerRight,
  });
}
