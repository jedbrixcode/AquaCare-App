class BackendConfig {
  static const String baseUrl = 'https://aquacare-5cyr.onrender.com';

  static Uri url(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized');
  }
}
