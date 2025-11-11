import 'package:aquacare_v5/core/services/local_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aquacare_v5/core/services/notifications_service.dart';
import 'package:aquacare_v5/core/services/connectivity_service.dart';
import 'package:aquacare_v5/firebase_options.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // 1. Local DB
    await LocalStorageService.instance.initialize();

    // 2. Connectivity (so onlineStream is available early)
    await ConnectivityService.instance.initialize();

    // 3. Firebase + FCM (retry if offline)
    await _initializeFirebaseWithRetry();
  }

  static Future<void> _initializeFirebaseWithRetry() async {
    int attempt = 0;
    const maxRetry = 10;

    while (attempt < maxRetry) {
      try {
        final online = await ConnectivityService.instance.isOnline();
        if (!online) throw Exception('Offline');

        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        await NotificationsService().init(silentOnFailure: true);
        break;
      } catch (e) {
        attempt++;
        final delay = Duration(
          milliseconds: 500 * (1 << attempt).clamp(0, 60000),
        );
        await Future.delayed(delay);
      }
    }
  }
}
