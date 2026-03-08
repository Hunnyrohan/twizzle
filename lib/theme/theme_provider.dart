import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:twizzle/core/services/light_sensor_service.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _box;
  final LightSensorService _lightService = LightSensorService();
  
  static const String _themeKey = 'isDarkMode';
  static const String _autoThemeKey = 'isAutoThemeEnabled';

  bool _isDarkMode = false;
  bool _isAutoThemeEnabled = false;

  bool get isDarkMode => _isDarkMode;
  bool get isAutoThemeEnabled => _isAutoThemeEnabled;

  ThemeProvider(this._box) {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = _box.get(_themeKey, defaultValue: false);
    _isAutoThemeEnabled = _box.get(_autoThemeKey, defaultValue: false);
    
    if (_isAutoThemeEnabled) {
      _startAutoMode();
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _box.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setAutoTheme(bool enabled) async {
    _isAutoThemeEnabled = enabled;
    await _box.put(_autoThemeKey, enabled);
    
    if (enabled) {
      _startAutoMode();
    } else {
      _stopAutoMode();
    }
    
    notifyListeners();
  }

  Timer? _transitionTimer;
  Timer? _fallbackCheckTimer;
  bool? _pendingTargetMode;
  bool _isSensorAvailable = true;

  bool get isSensorAvailable => _isSensorAvailable;

  void _startAutoMode() {
    print('💡 Light Sensor: Starting listener...');
    _lightService.startListening(
      onLuxChanged: (double lux) {
        _isSensorAvailable = true;
        _fallbackCheckTimer?.cancel();
        
        print('💡 Light Sensor: Lux = $lux (Current Mode: ${_isDarkMode ? 'DARK' : 'LIGHT'})');
        
        bool? immediateTargetIsDark;
        if (!_isDarkMode && lux < 10.0) {
          immediateTargetIsDark = true;
        } else if (_isDarkMode && lux > 20.0) {
          immediateTargetIsDark = false;
        }

        if (immediateTargetIsDark != null) {
          if (_pendingTargetMode == immediateTargetIsDark) return;

          print('⏳ Light Sensor: Detected threshold breach. Starting 2s confirmation timer...');
          _pendingTargetMode = immediateTargetIsDark;
          _transitionTimer?.cancel();
          _transitionTimer = Timer(const Duration(seconds: 2), () {
            print('✅ Light Sensor: 2s confirmation complete. Switching to ${_pendingTargetMode! ? 'DARK' : 'LIGHT'} mode');
            toggleTheme(_pendingTargetMode!);
            _pendingTargetMode = null;
          });
        } else {
          if (_pendingTargetMode != null) {
            _transitionTimer?.cancel();
            _pendingTargetMode = null;
          }
        }
        notifyListeners();
      },
      onError: (code, message) {
        print('🛑 Light Sensor Error: $code - $message');
        if (code == 'SENSOR_MISSING' || code == 'PLATFORM_NOT_SUPPORTED') {
          _isSensorAvailable = false;
          _startFallbackTimer();
          notifyListeners();
        }
      },
    );
  }

  void _startFallbackTimer() {
    _fallbackCheckTimer?.cancel();
    _checkTimeAndSetTheme();
    // Check every 5 minutes
    _fallbackCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkTimeAndSetTheme();
    });
  }

  void _checkTimeAndSetTheme() {
    if (!_isAutoThemeEnabled) return;
    
    final hour = DateTime.now().hour;
    // Dark mode from 7 PM (19) to 7 AM
    final shouldBeDark = hour >= 19 || hour < 7;
    
    if (_isDarkMode != shouldBeDark) {
      print('⏰ Time Fallback: Hour is $hour. Setting mode to ${shouldBeDark ? 'DARK' : 'LIGHT'}');
      toggleTheme(shouldBeDark);
    }
  }

  void _stopAutoMode() {
    _lightService.stopListening();
    _fallbackCheckTimer?.cancel();
    _transitionTimer?.cancel();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  void dispose() {
    _lightService.stopListening();
    super.dispose();
  }
}
