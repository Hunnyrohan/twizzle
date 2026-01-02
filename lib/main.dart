import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/home_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/login_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/signup_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/splash_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/onboarding_screen.dart';
import 'package:twizzle/widgets/custom_bottom_nav.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await di.init(); // Hive + DI
  runApp(
    ChangeNotifierProvider(
      create: (_) => di.sl<UserProvider>(),
      child: const TwizzleApp(),
    ),
  );
}

class TwizzleApp extends StatelessWidget {
  const TwizzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twizzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'OpenSans'),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1DA1F2),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      // remove 'home:'  ←←←  FIX HERE
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const CustomBottomNav(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/feed': (_) => const HomeFeedScreen(),
      },
    );
  }
}
