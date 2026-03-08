// lib/widgets/custom_bottom_nav.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/features/tweets/presentation/pages/home_feed_screen.dart';
// Note: Assuming these screens exist or will be refined later
// For now, using placeholders or the existing files if they exist
import 'package:twizzle/features/messages/presentation/pages/message_screen.dart';
import 'package:twizzle/features/messages/presentation/pages/call_screen.dart';
import 'package:twizzle/features/notifications/presentation/pages/notification_screen.dart';
import 'package:twizzle/features/notifications/presentation/providers/notification_provider.dart';
import 'package:twizzle/features/search/presentation/pages/search_screen.dart';
import 'package:twizzle/core/services/call_service.dart';
import 'package:twizzle/injection_container.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({Key? key}) : super(key: key);
  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _idx = 0;
  final _pages = [
    const HomeFeedScreen(),
    const SearchScreen(),
    const NotificationScreen(),
    const MessageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        final msgProvider = context.read<MessageProvider>();
        msgProvider.initSocket(user.id);
        
        // Load initial notification count
        context.read<NotificationProvider>().getUnreadCount();
        
        msgProvider.incomingCallStream.listen((callData) {
          if (mounted && !sl<CallService>().isInCall) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(
                  targetUserId: callData['from'],
                  targetUserName: callData['callerName'] ?? 'Unknown User',
                  targetUserAvatar: callData['callerImage'],
                  isVideo: callData['callType'] == 'video',
                  isIncoming: true,
                  offerData: callData['offer'],
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: BottomNavigationBar(
              currentIndex: _idx,
              onTap: (i) {
                setState(() => _idx = i);
                if (i == 3) {
                  context.read<MessageProvider>().loadConversations();
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 26),
                  activeIcon: Icon(Icons.home_filled, size: 28),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 26),
                  activeIcon: Icon(Icons.search_rounded, size: 28),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      return Badge(
                        label: provider.unreadCount > 0 ? Text(provider.unreadCount.toString()) : null,
                        isLabelVisible: provider.unreadCount > 0,
                        child: const Icon(Icons.notifications_outlined, size: 26),
                      );
                    },
                  ),
                  activeIcon: Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      return Badge(
                        label: provider.unreadCount > 0 ? Text(provider.unreadCount.toString()) : null,
                        isLabelVisible: provider.unreadCount > 0,
                        child: const Icon(Icons.notifications, size: 28),
                      );
                    },
                  ),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<MessageProvider>(
                    builder: (context, provider, child) {
                      return Badge(
                        label: provider.unreadCount > 0 
                            ? Text(provider.unreadCount.toString()) 
                            : null,
                        isLabelVisible: provider.unreadCount > 0 && _idx != 3,
                        child: const Icon(Icons.mail_outline, size: 26),
                      );
                    },
                  ),
                  activeIcon: Consumer<MessageProvider>(
                    builder: (context, provider, child) {
                      return Badge(
                        label: provider.unreadCount > 0 
                            ? Text(provider.unreadCount.toString()) 
                            : null,
                        isLabelVisible: provider.unreadCount > 0 && _idx != 3,
                        child: const Icon(Icons.mail, size: 28),
                      );
                    },
                  ),
                  label: 'Messages',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
