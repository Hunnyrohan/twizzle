// lib/presentation/widgets/profile_stats.dart
import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileStats({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Tweets', 42),
          _stat('Following', 123),
          _stat('Followers', 1.2),
        ],
      ),
    );
  }

  Widget _stat(String label, num count) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}