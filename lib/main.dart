import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/tweets/presentation/pages/home_feed_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/login_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/signup_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/splash_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/features/search/presentation/providers/search_provider.dart';
import 'package:twizzle/features/notifications/presentation/providers/notification_provider.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/theme/theme_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/onboarding_screen.dart';
import 'package:twizzle/widgets/custom_bottom_nav.dart';
import 'package:twizzle/widgets/biometric_wrapper.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/profile_screen.dart';
import 'package:twizzle/features/tweets/presentation/pages/lists_screen.dart';
import 'package:twizzle/features/tweets/presentation/pages/bookmarks_screen.dart';
import 'package:twizzle/features/tweets/presentation/pages/moments_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/features/messages/presentation/pages/chat_screen.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/edit_profile_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/forgot_password_screen.dart';
import 'package:twizzle/features/auth/domain/presentation/pages/connections_screen.dart';
import 'package:twizzle/features/settings/presentation/pages/settings_screen.dart';
import 'package:twizzle/features/settings/presentation/pages/server_settings_screen.dart';
import 'package:twizzle/features/settings/presentation/pages/blocked_accounts_screen.dart';
import 'package:twizzle/features/tweets/presentation/pages/tweet_detail_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Hive + DI
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TweetProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<SearchProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<MessageProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
      ],
      child: const TwizzleApp(),
    ),
  );
}

class TwizzleApp extends StatelessWidget {
  const TwizzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twizzle',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1DA1F2),
          primary: const Color(0xff1DA1F2),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'OpenSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xff1DA1F2)),
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 0.5,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1DA1F2),
          primary: const Color(0xff1DA1F2),
          surface: const Color(0xff15202b),
          brightness: Brightness.dark,
          background: const Color(0xff15202b),
        ),
        scaffoldBackgroundColor: const Color(0xff15202b),
        fontFamily: 'OpenSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff15202b),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xff1DA1F2)),
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white12,
          thickness: 0.5,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const CustomBottomNav(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/feed': (_) => const HomeFeedScreen(),
        '/lists': (_) => const ListsScreen(),
        '/bookmarks': (_) => const BookmarksScreen(),
        '/moments': (_) => const MomentsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/server-settings': (_) => const ServerSettingsScreen(),
        '/blocked-accounts': (_) => const BlockedAccountsScreen(),
      },
      builder: (context, child) {
        return BiometricWrapper(child: child!);
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final username = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(username: username),
          );
        }
        if (settings.name == '/chat') {
          final conversation = settings.arguments as Conversation;
          return MaterialPageRoute(
            builder: (_) => ChatScreen(conversation: conversation),
          );
        }
        if (settings.name == '/edit-profile') {
          return MaterialPageRoute(
            builder: (_) => const EditProfileScreen(),
          );
        }
        if (settings.name == '/connections') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ConnectionsScreen(
              username: args['username'] as String,
              initialTabIndex: args['initialTabIndex'] as int? ?? 0,
            ),
          );
        }
        if (settings.name == '/tweet-detail') {
          final tweetId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => TweetDetailScreen(tweetId: tweetId),
          );
        }
        return null;
      },
    );
  }
}
