import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/features/messages/presentation/pages/chat_screen.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/core/utils/media_utils.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<MessageProvider>().loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              actions: [
                IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff15202b) : Colors.white,
        ),
        child: provider.isLoading && provider.conversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.error.isNotEmpty
                ? Center(child: Text(provider.error))
                : provider.conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('Welcome to your inbox!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Drop a line, share a post and more with\nprivate conversations between you and others on Twizzle.', 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
                        itemCount: provider.conversations.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1, 
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                          indent: 85,
                        ),
                        itemBuilder: (context, index) {
                          final conversation = provider.conversations[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(conversation: conversation),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Profile Avatar with Navigation
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/profile', arguments: conversation.participantUsername),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                                        backgroundImage: conversation.participantAvatar.isNotEmpty
                                            ? NetworkImage(MediaUtils.resolveImageUrl(conversation.participantAvatar))
                                            : null,
                                        child: conversation.participantAvatar.isEmpty
                                            ? Text(
                                                conversation.participantName.isNotEmpty
                                                    ? conversation.participantName[0].toUpperCase()
                                                    : '?',
                                                style: TextStyle(
                                                  fontSize: 20, 
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : Colors.black87
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Name & Username
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, '/profile', arguments: conversation.participantUsername),
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  conversation.participantName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800, 
                                                    fontSize: 16,
                                                    color: isDark ? Colors.white : Colors.black,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (conversation.participantIsVerified) ...[
                                                const SizedBox(width: 4),
                                                const VerifiedBadge(size: 14),
                                              ],
                                              const SizedBox(width: 4),
                                              Text(
                                                '@${conversation.participantUsername}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500, 
                                                  fontSize: 14, 
                                                  fontWeight: FontWeight.w400
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                _getTime(conversation.lastMessageTime),
                                                style: TextStyle(
                                                  color: Colors.grey.shade500, 
                                                  fontSize: 13,
                                                  fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Message Preview Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                conversation.lastMessage,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: conversation.unreadCount > 0 
                                                      ? (isDark ? Colors.white : Colors.black87) 
                                                      : Colors.grey.shade500,
                                                  fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                                                  fontSize: 15,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ),
                                            if (conversation.unreadCount > 0)
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff1DA1F2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${conversation.unreadCount}',
                                                  style: const TextStyle(
                                                    color: Colors.white, 
                                                    fontSize: 11, 
                                                    fontWeight: FontWeight.w900
                                                  ),
                                                ),
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
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        heroTag: 'message_fab',
        backgroundColor: const Color(0xff1DA1F2),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.mail_outline, color: Colors.white, size: 28),
      ),
    );
  }

  String _getTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);
    
    if (localDateTime.year == now.year && localDateTime.month == now.month && localDateTime.day == now.day) {
      return DateFormat('h:mm a').format(localDateTime);
    }
    
    if (difference.inDays < 7) {
      return DateFormat('E').format(localDateTime); // Mon, Tue, etc.
    }
    
    return DateFormat('MMM d').format(localDateTime); // Jan 26, etc.
  }
}
