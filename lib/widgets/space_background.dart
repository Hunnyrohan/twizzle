import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final int _starCount = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _initStars();
  }

  void _initStars() {
    final random = Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2,
        velocity: random.nextDouble() * 0.05 + 0.01,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(_stars, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class Star {
  double x, y, size, velocity;
  Star({required this.x, required this.y, required this.size, required this.velocity});
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarfieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    
    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF000000),
          const Color(0xFF0A0A0A),
          const Color(0xFF1A1A1A),
        ],
      ).createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, bgPaint);

    for (var star in stars) {
      // Calculate animated position
      double dy = (star.y + (animationValue * star.velocity)) % 1.0;
      double dx = star.x;

      final offset = Offset(dx * size.width, dy * size.height);
      
      // Flickering effect based on sine wave
      final opacity = 0.3 + (0.7 * (0.5 + 0.5 * sin(animationValue * 20 + star.y * 100)));
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(offset, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
