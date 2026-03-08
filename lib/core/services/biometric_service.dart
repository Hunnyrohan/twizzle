import 'package:local_auth/local_auth.dart';
import 'package:hive/hive.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static String? _lastError;
  static bool _isAuthenticating = false;
  static bool _isLockPaused = false;

  static String? get lastError => _lastError;
  static bool get isAuthenticating => _isAuthenticating;
  static bool get isLockPaused => _isLockPaused;

  static void pauseLock() => _isLockPaused = true;
  static void resumeLock() => _isLockPaused = false;

  static bool isBiometricEnabledSync() {
    try {
      final box = Hive.box('settings');
      return box.get('biometricLock', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isBiometricEnabled() async {
    return isBiometricEnabledSync();
  }

  static Future<bool> canVerify() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      print('🚀 BIOMETRIC CHECK: canAuth=$canAuthenticateWithBiometrics, supported=$isDeviceSupported, available=${availableBiometrics.length}');
      
      // We return true if hardware exists OR if we allow PIN fallback (which is default)
      // On some platforms, isDeviceSupported covers PIN/Pattern too.
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (e) {
      print('🚀 BIOMETRIC CHECK ERROR: $e');
      return false;
    }
  }

  static Future<bool> authenticate({String reason = 'Please authenticate to continue'}) async {
    _lastError = null;
    _isAuthenticating = true;
    try {
      // Re-check availability
      final bool can = await canVerify();
      if (!can) {
        _lastError = 'Biometrics not set up or not supported.';
        _isAuthenticating = false;
        return false;
      }
      
      final bool success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (!success) _lastError = 'Authentication cancelled or failed.';
      _isAuthenticating = false;
      return success;
    } on Exception catch (e) {
      _isAuthenticating = false;
      _lastError = e.toString();
      if (e.toString().contains('NotAvailable')) {
        _lastError = 'Security credentials not available. Please set up a Screen Lock (PIN/Pattern) in phone settings.';
      }
      print('BiometricService Error: $_lastError');
      return false;
    }
  }
}
