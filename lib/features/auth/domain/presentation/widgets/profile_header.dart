// lib/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/presentation/widgets/frosted_glass.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileHeader({Key? key, required this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // cover
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://source.unsplash.com/600x200/?abstract'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // glass overlay
        Center(child: FrostedGlass(child: _avatarRow(context))),
      ],
    );
  }

  Widget _avatarRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=8'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rohan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('@rohan', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}