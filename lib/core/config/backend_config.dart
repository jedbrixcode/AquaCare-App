class BackendConfig {
  // --- Base URLs ---
  static const String flaskBaseUrl = 'https://aquacare-5cyr.onrender.com';
  static const String piCamBaseUrl = 'https://pi-cam.alfreds.dev';

  // --- Helper to build a full URL ---
  static Uri url(String path, {bool usePiCam = false}) {
    final base = usePiCam ? piCamBaseUrl : flaskBaseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized');
  }
}
