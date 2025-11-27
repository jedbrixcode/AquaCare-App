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
    // Check if online first - prioritize Firebase when online
    final online = await ConnectivityService.instance.isOnline();
    if (!online) {
      // App can run offline - skip Firebase initialization
      // Firebase will be initialized later when connectivity is restored
      return;
    }

    int attempt = 0;
    const maxRetry = 10;

    while (attempt < maxRetry) {
      try {
        // Double-check connectivity before each attempt
        final stillOnline = await ConnectivityService.instance.isOnline();
        if (!stillOnline) {
          // Went offline during retries - allow app to continue
          return;
        }

        // Check if Firebase is already initialized using a safer method
        if (Firebase.apps.isEmpty) {
          // Not initialized, initialize it now
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }

        // Verify Firebase is initialized before accessing services
        if (Firebase.apps.isNotEmpty) {
          await NotificationsService().init(silentOnFailure: true);
          break;
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetry) {
          // Max retries reached - allow app to continue in offline mode
          return;
        }
        final delay = Duration(
          milliseconds: 500 * (1 << attempt).clamp(0, 60000),
        );
        await Future.delayed(delay);
      }
    }
  }
}
