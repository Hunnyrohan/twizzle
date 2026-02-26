import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const VerifiedBadge({
    super.key,
    this.size = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Premium Blue used by X/Twitter
    final badgeColor = color ?? const Color(0xff1DA1F2);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        // Optional subtle glow if desired, but clean is often better
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.verified,
        size: size,
        color: badgeColor,
      ),
    );
  }
}
