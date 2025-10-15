import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aquacare_v5/core/services/notifications_service.dart';
import 'package:aquacare_v5/firebase_options.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, AsyncValue<void>>(
      (ref) => SplashViewModel(),
    );

class SplashViewModel extends StateNotifier<AsyncValue<void>> {
  SplashViewModel() : super(const AsyncValue.loading());

  Future<void> initializeApp() async {
    try {
      state = const AsyncValue.loading();

      // Isar init
      await LocalStorageService.instance.initialize();

      // Firebase init
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Notifications service init
      await NotificationsService().init();

      // FCM subscribe with retry and persist locally
      const topic = 'aquacare_alerts';
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        int attempt = 0;
        while (attempt < 5) {
          try {
            await FirebaseMessaging.instance.subscribeToTopic(topic);
            print("Subscribed to $topic");
            await LocalStorageService.instance.setFcmSubscribed(true);
            await LocalStorageService.instance.upsertSubscribedTopics([topic]);
            break;
          } catch (e) {
            attempt++;
            await Future.delayed(Duration(milliseconds: 500 * (1 << attempt)));
          }
        }
      }

      await Future.delayed(const Duration(seconds: 3));

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
