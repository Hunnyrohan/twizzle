import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/login_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/signup_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/forgot_password_screen.dart';
import 'package:twizzle/features/tweets/presentation/pages/home_feed_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twizzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1DA1F2)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeFeedScreen(),
      },
    );
  }
}