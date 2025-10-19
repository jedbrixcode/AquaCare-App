import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aquacare_v5/core/services/notifications_service.dart';
import 'package:aquacare_v5/firebase_options.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';
import 'package:aquacare_v5/core/services/connectivity_service.dart';
import 'dart:async';

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, AsyncValue<void>>(
      (ref) => SplashViewModel(),
    );

class SplashViewModel extends StateNotifier<AsyncValue<void>> {
  SplashViewModel() : super(const AsyncValue.loading());

  Future<void> initializeApp() async {
    try {
      state = const AsyncValue.loading();

      // Always ensure local DB is ready
      await LocalStorageService.instance.initialize();

      // Start background retry loop for Firebase/FCM regardless of connectivity
      _startBackgroundInitRetries();

      // Immediately proceed to app (offline-capable). Background retries will
      // upgrade capabilities when network/Firebase become available.
      state = const AsyncValue.data(null);
    } catch (e, _) {
      // If anything fails, proceed to app in offline-capable mode
      state = const AsyncValue.data(null);
    }
  }

  Timer? _retryTimer;
  void _startBackgroundInitRetries() {
    _retryTimer?.cancel();
    // Exponential backoff up to 5 minutes between attempts
    int attempt = 0;
    Future<void> tick() async {
      try {
        final online = await ConnectivityService.instance.isOnline();
        if (!online) {
          throw Exception('Offline');
        }

        // Firebase init (idempotent)
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Notifications init (local channel + FCM listeners)
        await NotificationsService().init(silentOnFailure: true);

        // Try FCM token + topic subscription
        const topic = 'aquacare_alerts';
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          try {
            await FirebaseMessaging.instance.subscribeToTopic(topic);
            await LocalStorageService.instance.setFcmSubscribed(true);
            await LocalStorageService.instance.upsertSubscribedTopics([topic]);
          } catch (_) {}
        }

        // Success → stop retries
        _retryTimer?.cancel();
        _retryTimer = null;
        return;
      } catch (_) {
        attempt = attempt + 1;
        final delayMs = _capBackoffMs(500 * (1 << (attempt.clamp(0, 10))));
        _retryTimer = Timer(Duration(milliseconds: delayMs), tick);
      }
    }

    // Kick off
    unawaited(tick());
  }

  int _capBackoffMs(int ms) {
    // Cap to 5 minutes
    const maxMs = 5 * 60 * 1000;
    return ms > maxMs ? maxMs : ms;
  }
}
