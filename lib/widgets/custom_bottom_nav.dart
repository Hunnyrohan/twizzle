import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({Key? key}) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _idx = 0;

  final _pages = [
    const Center(child: Text('Home',       style: TextStyle(fontFamily: 'OpenSans'))),
    const Center(child: Text('Search',     style: TextStyle(fontFamily: 'OpenSans'))),
    const Center(child: Text('Messages',   style: TextStyle(fontFamily: 'OpenSans'))),
    const Center(child: Text('Notifications', style: TextStyle(fontFamily: 'OpenSans'))),
    const Center(child: Text('Profile',    style: TextStyle(fontFamily: 'OpenSans'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),

      // FAB only on Messages tab
      floatingActionButton: _idx == 2
          ? FloatingActionButton(
              onPressed: () => _showNewChat(context),
              backgroundColor: const Color(0xff1DA1F2),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff1DA1F2),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), activeIcon: Icon(Icons.mail), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showNewChat(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New Chat', style: TextStyle(fontFamily: 'OpenSans', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xff1DA1F2)),
              title: const Text('Start direct message', style: TextStyle(fontFamily: 'OpenSans')),
              onTap: () => Navigator.pop(ctx), // TODO: push DM screen
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xff1DA1F2)),
              title: const Text('Create group', style: TextStyle(fontFamily: 'OpenSans')),
              onTap: () => Navigator.pop(ctx), // TODO: push group screen
            ),
          ],
        ),
      ),
    );
  }
}