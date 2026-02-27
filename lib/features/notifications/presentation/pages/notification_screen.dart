import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/notifications/presentation/providers/notification_provider.dart';
import 'package:twizzle/features/notifications/domain/entities/notification.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<NotificationProvider>().loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: theme.colorScheme.primary),
            tooltip: 'Mark all as read',
            onPressed: () => provider.markAllAsRead(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadNotifications(),
        child: provider.isLoading && provider.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.error.isNotEmpty
                ? Center(child: Text(provider.error))
                : provider.notifications.isEmpty
                    ? const Center(child: Text('No notifications yet'))
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.notifications.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: theme.dividerColor.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final notification = provider.notifications[index];
                          return NotificationItem(notification: notification);
                        },
                      ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final UserNotification notification;

  const NotificationItem({Key? key, required this.notification}) : super(key: key);

  IconData _getIcon() {
    switch (notification.type) {
      case 'like': return Icons.favorite;
      case 'follow': return Icons.person_add;
      case 'mention': return Icons.alternate_email;
      case 'comment': return Icons.chat_bubble_outline;
      case 'repost': return Icons.repeat;
      case 'bookmark': return Icons.bookmark_border;
      default: return Icons.notifications_none;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case 'like': return Colors.red;
      case 'follow': return Colors.blue;
      case 'mention': return Colors.purple;
      case 'comment': return Colors.green;
      case 'repost': return Colors.blueAccent;
      case 'bookmark': return Colors.orange;
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<NotificationProvider>();
    
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          provider.markAsRead(notification.id);
        }
        
        if (notification.type == 'follow') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(username: notification.authorUsername),
            ),
          );
        } else if (notification.tweetId != null) {
          Navigator.pushNamed(
            context,
            '/tweet-detail',
            arguments: notification.tweetId,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: notification.isRead ? null : theme.colorScheme.primary.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon & Avatar Column
            Column(
              children: [
                Icon(_getIcon(), size: 20, color: _getIconColor(context)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CustomImage(
                    imageUrl: MediaUtils.resolveImageUrl(notification.authorAvatar),
                    width: 40,
                    height: 40,
                    errorWidget: Container(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          notification.authorName.isNotEmpty ? notification.authorName[0] : '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info & Content
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      children: [
                        TextSpan(
                          text: notification.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (notification.authorIsVerified) ...[
                          const WidgetSpan(child: SizedBox(width: 4)),
                          const WidgetSpan(child: VerifiedBadge(size: 14)),
                        ],
                        TextSpan(
                          text: ' ${notification.content}',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                        ),
                        TextSpan(
                          text: ' · ${_getTimeAgo(notification.createdAt)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  
                  // Comment Preview
                  if (notification.commentText != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${notification.commentText}"',
                        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // Post Preview
                  if (notification.postPreviewContent != null || notification.postPreviewImage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (notification.postPreviewImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomImage(
                                imageUrl: MediaUtils.resolveImageUrl(notification.postPreviewImage),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              notification.postPreviewContent ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Unread Indicator
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return 'now';
  }
}
