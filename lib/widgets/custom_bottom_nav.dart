// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import '../features/auth/domain/presentation/pages/home_screen.dart';
import '../features/auth/domain/presentation/pages/search_screen.dart';
import '../features/auth/domain/presentation/pages/message_screen.dart';
import '../features/auth/domain/presentation/pages/notification_screen.dart';
import '../features/auth/domain/presentation/pages/profile_screen.dart';

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

      // ------------------  NEW COLOURS  ------------------
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xff1DA1F2)),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white, // active icon + label
          unselectedItemColor: Colors.white70, // inactive
          selectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              activeIcon: Icon(Icons.mail),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
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
