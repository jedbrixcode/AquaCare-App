import 'package:aquacare_v5/core/navigation/route_observer.dart';
import 'package:flutter/material.dart';
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

      // Ensure the widget bindings and lifecycle observer are ready
      WidgetsFlutterBinding.ensureInitialized();
      WidgetsBinding.instance.addObserver(AppLifecycleHandler());

      // Initialize local DB first
      await LocalStorageService.instance.initialize();

      // Start Firebase/FCM background retry process
      _startBackgroundInitRetries();

      // App can still start even offline (Firebase can retry later)
      state = const AsyncValue.data(null);
    } catch (e) {
      debugPrint('App initialization failed: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      state = const AsyncValue.data(null);
    }
  }

  Timer? _retryTimer;

  void _startBackgroundInitRetries() {
    _retryTimer?.cancel();
    int attempt = 0;

    Future<void> tick() async {
      try {
        final online = await ConnectivityService.instance.isOnline();
        if (!online) throw Exception('Offline');

        // Initialize Firebase (idempotent)
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Initialize notifications and listeners
        await NotificationsService().init(silentOnFailure: true);

        // Subscribe to FCM topic
        const topic = 'aquacare_alerts';
        String? token = await FirebaseMessaging.instance.getToken();

        if (token != null) {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          await LocalStorageService.instance.setFcmSubscribed(true);
          await LocalStorageService.instance.upsertSubscribedTopics([topic]);
        }

        // ✅ SUCCESS
        debugPrint('✅ Firebase + FCM successfully connected. Token: $token');

        // Stop retries after success
        _retryTimer?.cancel();
        _retryTimer = null;
        return;
      } catch (e) {
        attempt += 1;
        final delayMs = _capBackoffMs(500 * (1 << (attempt.clamp(0, 10))));
        debugPrint(
          '⚠️ Firebase init attempt #$attempt failed ($e). Retrying in ${delayMs ~/ 1000}s...',
        );
        _retryTimer = Timer(Duration(milliseconds: delayMs), tick);
      }
    }

    unawaited(tick());
  }

  int _capBackoffMs(int ms) {
    // Cap exponential backoff at 5 minutes
    const maxMs = 5 * 60 * 1000;
    return ms > maxMs ? maxMs : ms;
  }
}
