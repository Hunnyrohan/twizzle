/// Central configuration for the app.
///
/// 🌐 NGROK MODE (active): Backend tunneled via ngrok.
/// Works over any internet connection (WiFi or mobile data).
///
/// ⚠️ The ngrok URL changes every time you restart ngrok (free plan).
/// Update [_ngrokUrl] with your new URL and rebuild the app.
///
/// 🏠 LOCAL MODE: Set [_useNgrok] to false to use local WiFi instead.
class AppConfig {
  // ── Defaults (used when Hive is empty) ───────────────────────────────────
  static const bool useNgrokDefault = false;
  static const String ngrokUrlDefault = 'https://karis-awless-ela.ngrok-free.dev';
  static const String serverIp = '192.168.1.84';
  static const int serverPort = 5050;

  // ── Resolved URLs (Legacy support, but DioClient uses dynamic logic now) ──
  static String get baseApiUrl => useNgrokDefault
      ? '$ngrokUrlDefault/api'
      : 'http://$serverIp:$serverPort/api';

  static String get baseUrl => useNgrokDefault
      ? ngrokUrlDefault
      : 'http://$serverIp:$serverPort';

  static String get uploadsUrl => useNgrokDefault
      ? '$ngrokUrlDefault/uploads/'
      : 'http://$serverIp:$serverPort/uploads/';
}
