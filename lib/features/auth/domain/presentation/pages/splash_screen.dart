// lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:twizzle/injection_container.dart' as di;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:twizzle/widgets/space_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    print('🚀 SPLASH: starting navigation');
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      final box = di.sl<Box>();
      final user = box.get('user');
      print('🚀 SPLASH: user = $user');

      final route = user == null ? '/onboarding' : '/home';
      print('🚀 SPLASH: pushing $route');

      Navigator.pushReplacementNamed(context, route);
    } catch (e, s) {
      print('🚀 SPLASH ERROR: $e  \n$s');
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          Center(
            child: Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 1000)),
                ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
              ],
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1DA1F2).withOpacity(0.4),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/app_logo.jpeg',
                      height: 140, // Larger for splash
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.flutter_dash,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(duration: 3.seconds, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
