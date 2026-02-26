// lib/widgets/custom_bottom_nav.dart  (only bottomNavigationBar changed)
import 'package:flutter/material.dart';
import 'package:twizzle/features/tweets/presentation/pages/home_feed_screen.dart';
import 'package:twizzle/features/messages/presentation/pages/message_screen.dart';
import 'package:twizzle/features/notifications/presentation/pages/notification_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/profile_screen.dart';
import 'package:twizzle/features/search/presentation/pages/search_screen.dart';

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
    const MessageScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      floatingActionButton: _idx == 0
          ? FloatingActionButton(
              onPressed: () => _showCompose(context),
              backgroundColor: const Color(0xff1DA1F2),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      // ➜➜➜  NEW ATTRACTIVE BAR  (copy from here)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.white),
            child: BottomNavigationBar(
              currentIndex: _idx,
              onTap: (i) => setState(() => _idx = i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xff1DA1F2),
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
              showUnselectedLabels: true,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mail_outline),
                  activeIcon: Icon(Icons.mail),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Alerts',
                ), // ← shorter
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompose(BuildContext ctx) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "What's happening?",
                  border: InputBorder.none,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tweet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
