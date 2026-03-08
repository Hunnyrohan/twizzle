import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:twizzle/core/config/app_config.dart';

class DioClient {
  final Dio _dio;

  static String? _dynamicBaseUrl;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseApiUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // 1. ADD TOKEN IF EXISTS
          final box = await Hive.openBox('userBox');
          final userData = box.get('user');
          if (userData != null) {
            final token = userData['token'];
            if (token != null && (token as String).isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // 2. HANDLE BASE URL
          if (_dynamicBaseUrl != null) {
            if (!options.path.startsWith('http')) {
              if (options.path.startsWith('/') && _dynamicBaseUrl!.endsWith('/')) {
                options.path = options.path.substring(1);
              }
              options.baseUrl = _dynamicBaseUrl!;
            }
          } else if (!options.path.startsWith('http')) {
            final settingsBox = await Hive.openBox('settings');
            final useNgrok = settingsBox.get('useNgrok') ?? AppConfig.useNgrokDefault;
            
            if (useNgrok) {
              final ngrokUrl = settingsBox.get('ngrokUrl') ?? AppConfig.ngrokUrlDefault;
              if (ngrokUrl != null && (ngrokUrl as String).isNotEmpty) {
                options.baseUrl = '$ngrokUrl/api/';
              }
            } else {
              final customIp = settingsBox.get('serverIp') ?? AppConfig.serverIp;
              final customPort = settingsBox.get('serverPort') ?? AppConfig.serverPort;
              options.baseUrl = 'http://$customIp:$customPort/api/';
            }
          }
        } catch (e) {
          print('DioClient: Error in Interceptor: $e');
        }
        return handler.next(options);
      },
    ));

    // LogInterceptor MUST be last to see the final resolved URL
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  void updateBaseUrl(String newUrl) {
    String normalized = newUrl.endsWith('/') ? newUrl : '$newUrl/';
    _dynamicBaseUrl = normalized.endsWith('api/') ? normalized : '${normalized}api/';
    _dio.options.baseUrl = _dynamicBaseUrl!;
  }

  static void setStaticBaseUrl(String newUrl) {
    String normalized = newUrl.endsWith('/') ? newUrl : '$newUrl/';
    _dynamicBaseUrl = normalized.endsWith('api/') ? normalized : '${normalized}api/';
  }

  static String getResolvedBaseUrl() {
    if (_dynamicBaseUrl != null) {
      return _dynamicBaseUrl!.replaceFirst('/api/', '');
    }
    return AppConfig.baseUrl; // Fallback to config
  }

  static Future<String?> discoverAndSetBackend() async {
    final settingsBox = await Hive.openBox('settings');
    final List<String> candidates = [
      // 1. Saved Custom URL
      if (settingsBox.get('useNgrok') == false) 
        'http://${settingsBox.get('serverIp') ?? AppConfig.serverIp}:${settingsBox.get('serverPort') ?? AppConfig.serverPort}',
      
      // 2. Saved ngrok
      if (settingsBox.get('useNgrok') == true)
        '${settingsBox.get('ngrokUrl') ?? AppConfig.ngrokUrlDefault}',

      // 3. Emulator Host
      'http://10.0.2.2:5050',
      
      // 4. Current known Local IP
      'http://${AppConfig.serverIp}:${AppConfig.serverPort}',
      
      // 5. Default ngrok
      AppConfig.ngrokUrlDefault,
    ];

    // Remove duplicates and nulls
    final uniqueCandidates = candidates.toSet().toList();
    
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 2)));
    
    print('🧐 DISCOVERY: Trying ${uniqueCandidates.length} potential servers...');

    for (final url in uniqueCandidates) {
      try {
        final res = await dio.get('$url/health');
        if (res.statusCode == 200 && (res.data as Map)['status'] == 'OK') {
          print('✅ DISCOVERY: Found working server at $url');
          setStaticBaseUrl(url);
          // Save this as the preferred one for next time
          if (url.contains('10.0.2.2') || url.contains('192.168')) {
            await settingsBox.put('useNgrok', false);
            if (url.contains('10.0.2.2')) await settingsBox.put('serverIp', '10.0.2.2');
          } else if (url.contains('ngrok')) {
             await settingsBox.put('useNgrok', true);
             await settingsBox.put('ngrokUrl', url);
          }
          return url;
        }
      } catch (_) {
        // Continue to next candidate
      }
    }
    
    print('❌ DISCOVERY: No server found automatically.');
    return null;
  }

  Dio get dio => _dio;

  // Generic request methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}
