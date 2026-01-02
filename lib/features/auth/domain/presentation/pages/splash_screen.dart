// lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/injection_container.dart' as di;
import '../providers/user_provider.dart';
import 'package:hive/hive.dart';

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
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final box = di.sl<Box>();
      final user = box.get('user');
      print('🚀 SPLASH: user = $user');

      final route = user == null ? '/onboarding' : '/feed';
      print('🚀 SPLASH: pushing $route');

      Navigator.pushReplacementNamed(context, route);
    } catch (e, s) {
      print('🚀 SPLASH ERROR: $e  \n$s');
      // fallback to login if anything breaks
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flutter_dash, size: 72, color: Color(0xff1DA1F2)),
            SizedBox(height: 16),
            Text(
              'Twizzle',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
