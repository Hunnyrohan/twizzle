import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/notifications/presentation/providers/notification_provider.dart';
import 'package:twizzle/features/notifications/domain/entities/notification.dart';
import 'package:twizzle/widgets/verified_badge.dart';


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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
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
                        itemCount: provider.notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = provider.notifications[index];
                          return ListTile(
                            tileColor: notification.isRead ? null : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            leading: CircleAvatar(
                              backgroundImage: notification.authorAvatar.isNotEmpty
                                  ? NetworkImage(notification.authorAvatar)
                                  : null,
                              child: notification.authorAvatar.isEmpty
                                  ? Text(notification.authorName.isNotEmpty
                                      ? notification.authorName[0]
                                      : '?')
                                  : null,
                            ),
                            title: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontFamily: 'OpenSans',
                                ),
                                children: [
                                  TextSpan(
                                    text: notification.authorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (notification.authorIsVerified)
                                    const WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4, right: 2),
                                        child: VerifiedBadge(size: 14),
                                      ),
                                    ),
                                  TextSpan(text: ' ${notification.content}'),

                                ],
                              ),
                            ),
                            subtitle: Text(
                              _getTimeAgo(notification.createdAt),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            onTap: () {
                              if (!notification.isRead) {
                                provider.markAsRead(notification.id);
                              }
                              // Navigate to tweet if applicable
                            },
                          );
                        },
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
