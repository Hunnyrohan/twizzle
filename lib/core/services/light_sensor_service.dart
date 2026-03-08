import 'dart:async';
import 'package:flutter/services.dart';

class LightSensorService {
  static const _channel = EventChannel('com.rohan.twizzle/light_sensor');
  StreamSubscription? _subscription;
  
  // Callback when lux changes
  void startListening({
    required Function(double lux) onLuxChanged,
    required Function(String code, String message) onError,
  }) {
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (lux) {
          if (lux is double) {
            onLuxChanged(lux);
          } else if (lux is int) {
            onLuxChanged(lux.toDouble());
          }
        },
        onError: (e) {
          if (e is PlatformException) {
            onError(e.code, e.message ?? 'Unknown sensor error');
          } else {
            onError('UNKNOWN', e.toString());
          }
        },
      );
    } catch (e) {
      print('Native Light Sensor not supported: $e');
      onError('PLATFORM_NOT_SUPPORTED', e.toString());
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
