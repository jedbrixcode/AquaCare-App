import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/notifications_service.dart';
import '../../../firebase_options.dart';

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, AsyncValue<void>>(
      (ref) => SplashViewModel(ref),
    );

class SplashViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SplashViewModel(this.ref) : super(const AsyncValue.loading());

  Future<void> initializeApp() async {
    try {
      // Firebase init
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Notifications
      await NotificationsService().init();

      // Subscribe to FCM
      const topic = 'aquacare_alerts';
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }

      // Done
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
