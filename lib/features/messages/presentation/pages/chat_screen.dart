import 'dart:ui';
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
  String _currentUserId = '';
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    // Cache the user ID immediately in state so it doesn't change across rebuilds
    Future.microtask(() {
      _currentUserId = context.read<UserProvider>().user?.id ?? '';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          targetUserId: widget.conversation.participantId,
          targetUserName: widget.conversation.participantName,
          targetUserAvatar: widget.conversation.participantAvatar,
          isVideo: video,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    // Use cached _currentUserId for alignment to avoid race conditions
    final userId = _currentUserId.isNotEmpty 
        ? _currentUserId 
        : (context.read<UserProvider>().user?.id ?? '');
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
              title: Row(
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
                        return _buildMessageBubble(message, isMe);
                      },
                    ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: isMe ? 60 : 16,
              right: isMe ? 16 : 60,
              top: 4,
              bottom: 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearRouteGradient(
                      colors: [Color(0xff1DA1F2), Color(0xff0C85D0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                if (isMe)
                  BoxShadow(
                    color: const Color(0xff1DA1F2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: message.type == 'image' && message.mediaUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.mediaUrl!,
                      width: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : const SizedBox(
                                  width: 200, height: 150,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                    ),
                  )
                : Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: isMe ? 0.2 : -0.2, curve: Curves.easeOutCubic),
        ],
      ),
    );
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
