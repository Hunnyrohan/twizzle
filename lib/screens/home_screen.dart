import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twizzle'),
        backgroundColor: const Color(0xFF1DA1F2),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF1DA1F2),
                        child: Text('U'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'User $index',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text('${index}h ago', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('This is a sample tweet #$index. Welcome to Twizzle!'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1DA1F2),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
        ],
        selectedItemColor: const Color(0xFF1DA1F2),
        onTap: (index) {},
      ),
    );
  }
}
