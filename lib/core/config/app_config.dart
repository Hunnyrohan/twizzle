/// Central configuration for the app.
/// 
/// ⚠️ IMPORTANT: Change [serverIp] to your machine's local network IP
/// when running on a physical device (emulator uses 10.0.2.2, physical
/// devices need your PC's actual LAN IP like 192.168.1.x).
///
/// To find your IP: run `ipconfig` on Windows and look for "IPv4 Address".
class AppConfig {
  /// Your server's LAN IP address (used by physical devices).
  /// Change this if your machine's IP changes.
  static const String serverIp = '192.168.1.84';

  static const int serverPort = 5000;

  static const String baseApiUrl = 'http://$serverIp:$serverPort/api';

  static const String baseUrl = 'http://$serverIp:$serverPort';

  static const String uploadsUrl = 'http://$serverIp:$serverPort/uploads/';
}
