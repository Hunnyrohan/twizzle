import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'widgets/custom_bottom_nav.dart'; // <- new

void main() => runApp(const TwizzleApp());

class TwizzleApp extends StatelessWidget {
  const TwizzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twizzle',
      debugShowCheckedModeBanner: false,

      /* ---------- unified theme ---------- */
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF1DA1F2)),
        scaffoldBackgroundColor: Colors.white,

        // main text theme (Roboto from Google Fonts)
        textTheme: GoogleFonts.robotoTextTheme(),

        // app-bar uses OpenSans for titles
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1DA1F2),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DA1F2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        // text-fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1DA1F2)),
          ),
        ),
      ),

      /* ---------- routes ---------- */
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const CustomBottomNav(), // <- bottom nav host
      },
    );
  }

  /* helper to convert single colour to MaterialColor */
  MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
