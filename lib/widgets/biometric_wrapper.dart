import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/core/services/biometric_service.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';

class BiometricWrapper extends StatefulWidget {
  final Widget child;
  const BiometricWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<BiometricWrapper> createState() => _BiometricWrapperState();
}

class _BiometricWrapperState extends State<BiometricWrapper> with WidgetsBindingObserver {
  bool _isAuthenticated = true; // Start authenticated (splash handles initial)
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🚀 APP LIFECYCLE: $state');
    if (state == AppLifecycleState.resumed) {
      _checkLock();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Don't lock if WE are currently showing a biometric prompt (which makes app inactive)
      if (BiometricService.isAuthenticating || BiometricService.isLockPaused) {
        print('🚀 SECURITY: Ignoring inactive state (auth=${BiometricService.isAuthenticating}, paused=${BiometricService.isLockPaused})');
        return;
      }

      // Use synchronous check to prevent race conditions during fast transitions
      final bool enabled = BiometricService.isBiometricEnabledSync();
      if (enabled && _isAuthenticated) {
        print('🚀 SECURITY: Locking app due to $state');
        setState(() => _isAuthenticated = false);
      }
    }
  }

  Future<void> _checkLock() async {
    final enabled = await BiometricService.isBiometricEnabled();
    if (enabled && !_isAuthenticated && !_isAuthenticating) {
      _isAuthenticating = true;
      final success = await BiometricService.authenticate(
        reason: 'Please authenticate to resume Twizzle',
      );
      if (success) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      } else {
        _isAuthenticating = false;
        // If they cancel, they stay on the lock screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xff15202b),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Color(0xff1DA1F2)),
              const SizedBox(height: 24),
              const Text(
                'Twizzle is Locked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (BiometricService.lastError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Text(
                    BiometricService.lastError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _checkLock,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1DA1F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              if (BiometricService.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () async {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      await userProvider.logout();
                      final settingsBox = await Hive.box('settings');
                      await settingsBox.put('biometricLock', false);
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/splash');
                      }
                    },
                    child: const Text('Sign Out & Reset Lock', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
