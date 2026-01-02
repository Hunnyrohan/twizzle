// lib/presentation/widgets/frosted_glass.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  const FrostedGlass({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: child,
      ),
    );
  }
}