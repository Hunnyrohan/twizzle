// lib/widgets/drawer_menu.dart
import 'package:flutter/material.dart';
class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff1DA1F2), Color(0xff0066CC)])),
            accountName: const Text('John Doe'),
            accountEmail: const Text('@johndoe'),
            currentAccountPicture: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3')),
          ),
          ListTile(leading: const Icon(Icons.person, color: Color(0xff1DA1F2)), title: const Text('Profile'), onTap: () {}),
          ListTile(leading: const Icon(Icons.bookmark_border, color: Color(0xff1DA1F2)), title: const Text('Bookmarks'), onTap: () {}),
          ListTile(leading: const Icon(Icons.logout, color: Color(0xff1DA1F2)), title: const Text('Log out'), onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }
}