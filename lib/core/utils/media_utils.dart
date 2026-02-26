class MediaUtils {
  static const String _imageBaseUrl = 'http://10.0.2.2:5000/uploads/';

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // If it's already a full URL (but check for localhost)
    if (path.startsWith('http')) {
      return path.replaceAll('localhost', '10.0.2.2');
    }
    
    // If it's just a filename
    return '$_imageBaseUrl$path';
  }
}
