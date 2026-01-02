// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../../../../widgets/drawer_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: const DrawerMenu(), // reusable drawer
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: ListView(
          children: const [
            ListTile(title: Text('Tweet 1')),
            ListTile(title: Text('Tweet 2')),
            ListTile(title: Text('Tweet 3')),
          ],
        ),
      ),
    );
  }
}