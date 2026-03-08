import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/injection_container.dart' as di;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:twizzle/widgets/space_background.dart';
import 'package:local_auth/local_auth.dart';
import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/core/config/app_config.dart';
import 'package:twizzle/core/services/biometric_service.dart';

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

  bool _isSearching = false;
  String? _statusText;

  Future<void> _navigate() async {
    print('🚀 SPLASH: starting navigation');
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      setState(() { _isSearching = true; _statusText = 'Searching for server...'; });
      final foundUrl = await DioClient.discoverAndSetBackend();
      setState(() { _isSearching = false; });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isLoggedIn = await userProvider.checkLoggedIn();
      print('🚀 SPLASH: isLoggedIn = $isLoggedIn, Server = $foundUrl, Error = ${userProvider.error}');

      // IF discovery failed (null) OR there's a connection error, show the dialog
      final isConnectionError = userProvider.error.toLowerCase().contains('connect') || 
                                userProvider.error.toLowerCase().contains('offline') ||
                                userProvider.error.toLowerCase().contains('backend') ||
                                userProvider.error.toLowerCase().contains('unreachable');

      if (foundUrl == null || isConnectionError) {
        print('🚀 SPLASH: Connection issue detected, showing dialog');
        _showConnectionDialog(userProvider.error.isEmpty ? 'Could not discover backend server.' : userProvider.error);
        return;
      }

      if (isLoggedIn) {
        // Check for Biometric Lock
        final box = Hive.box('settings');
        final isLockEnabled = box.get('biometricLock', defaultValue: false);

        if (isLockEnabled) {
          print('🚀 SPLASH: Biometric Lock is ACTIVE');
          setState(() { 
            _isSearching = true; 
            _statusText = 'Authentication required...'; 
          });
          
          final bool didAuthenticate = await BiometricService.authenticate(
            reason: 'Please authenticate to open Twizzle',
          );
          print('🚀 SPLASH: Auth result = $didAuthenticate');

          if (!didAuthenticate) {
            setState(() {
              _isSearching = false;
              _statusText = BiometricService.lastError ?? 'Authentication failed. Tap logo to retry.';
            });
            return; // STOP navigation here
          }
        }
      }

      final route = !isLoggedIn ? '/onboarding' : '/home';
      print('🚀 SPLASH: pushing $route');
      
      if (!mounted) {
        print('🚀 SPLASH: widget unmounted, skipping nav');
        return;
      }
      
      Navigator.pushReplacementNamed(context, route);
    } catch (e, s) {
      print('🚀 SPLASH ERROR: $e  \n$s');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  void _showConnectionDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Connection Problem'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 16),
              const Text('The app cannot reach the server.', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('📱 Physical Device Tips:', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              const Text('• Set WiFi to "Private" (not Public) on your PC.', style: TextStyle(fontSize: 12)),
              const Text('• Disable Windows Firewall OR allow port 5050.', style: TextStyle(fontSize: 12)),
              const Text('• Ensure Phone & PC are on the SAME WiFi.', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              const Text('How would you like to connect?'),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              _buildConnectionOption(
                'Use Emulator (10.0.2.2)',
                'http://10.0.2.2:5050',
                Icons.computer,
              ),
              _buildConnectionOption(
                'Use Local IP (Home WiFi)',
                'http://${AppConfig.serverIp}:${AppConfig.serverPort}',
                Icons.router,
              ),
              _buildConnectionOption(
                'Configure ngrok / Custom',
                null,
                Icons.settings,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/server-settings').then((_) => _navigate());
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _navigate(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionOption(String title, String? url, IconData icon, {VoidCallback? onPressed}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: url != null ? Text(url, style: const TextStyle(fontSize: 12)) : null,
      onTap: onPressed ?? () async {
        if (url != null) {
          final settingsBox = await Hive.openBox('settings');
          if (url.contains('10.0.2.2')) {
             await settingsBox.put('useNgrok', false);
             await settingsBox.put('serverIp', '10.0.2.2');
          } else {
             await settingsBox.put('useNgrok', false);
             await settingsBox.put('serverIp', AppConfig.serverIp);
          }
          DioClient.setStaticBaseUrl('$url/api');
          if (mounted) Navigator.pop(context);
          _navigate();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          Center(
            child: GestureDetector(
              onTap: () {
                if (_statusText != null && _statusText!.contains('failed')) {
                  _navigate();
                }
              },
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
          ),
          if (_isSearching)
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: Column(
                children: [
                   const CircularProgressIndicator(color: Colors.blue),
                   const SizedBox(height: 16),
                   Text(
                     _statusText ?? 'Connecting to Twizzle...',
                     textAlign: TextAlign.center,
                     style: const TextStyle(color: Colors.white70, fontSize: 13),
                   ),
                   if (_statusText != null && _statusText!.contains('failed') || 
                       _statusText != null && _statusText!.contains('Security'))
                     Padding(
                       padding: const EdgeInsets.only(top: 16),
                       child: TextButton(
                         onPressed: () async {
                           final userProvider = Provider.of<UserProvider>(context, listen: false);
                           await userProvider.logout();
                           // Clear biometric setting too in case they are stuck
                           final settingsBox = await Hive.openBox('settings');
                           await settingsBox.put('biometricLock', false);
                           _navigate();
                         },
                         child: const Text('Sign Out & Reset Lock', style: TextStyle(color: Colors.blueAccent)),
                       ),
                     ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
