import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/core/config/app_config.dart';

class MediaUtils {
  static String get _imageBaseUrl {
    final resolvedBase = DioClient.getResolvedBaseUrl();
    return resolvedBase.endsWith('/') ? '${resolvedBase}uploads/' : '$resolvedBase/uploads/';
  }

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // If it's already a full URL or relative path starting with http/https
    if (path.startsWith('http')) {
      // Replace any old emulator or localhost references with the real server IP
      final resolvedBase = DioClient.getResolvedBaseUrl();
      // Extract IP/host from resolvedBase to replace others
      String currentHost = AppConfig.serverIp;
      try {
         final uri = Uri.parse(resolvedBase);
         currentHost = uri.host;
      } catch (_) {}

      return path
          .replaceAll('localhost', currentHost)
          .replaceAll('10.0.2.2', currentHost)
          .replaceAll('192.168.1.84', currentHost); // Also replace the user's specific IP if it's hardcoded
    }
    
    // Remove leading slash if exists
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // If path already contains uploads/, don't prepend it again
    if (cleanPath.startsWith('uploads/')) {
      final resolvedBase = DioClient.getResolvedBaseUrl();
      final baseNoSlash = resolvedBase.endsWith('/') ? resolvedBase.substring(0, resolvedBase.length - 1) : resolvedBase;
      return '$baseNoSlash/$cleanPath';
    }
    
    // Otherwise prepend the full base path
    return '$_imageBaseUrl$cleanPath';
  }
}
