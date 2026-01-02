// lib/presentation/screens/home_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:twizzle/widgets/drawer_menu.dart';


class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      drawer: const DrawerMenu(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xff1DA1F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}