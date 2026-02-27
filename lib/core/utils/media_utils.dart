import 'package:twizzle/core/config/app_config.dart';

class MediaUtils {
  static String get _imageBaseUrl => AppConfig.uploadsUrl;

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // If it's already a full URL or relative path starting with http/https
    if (path.startsWith('http')) {
      // Replace any old emulator or localhost references with the real server IP
      return path
          .replaceAll('localhost', AppConfig.serverIp)
          .replaceAll('10.0.2.2', AppConfig.serverIp);
    }
    
    // Remove leading slash if exists
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // If path already contains uploads/, don't prepend it again
    if (cleanPath.startsWith('uploads/')) {
      return '${AppConfig.baseUrl}/$cleanPath';
    }
    
    // Otherwise prepend the full base path
    return '$_imageBaseUrl$cleanPath';
  }
}
