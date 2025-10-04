import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/notifications_service.dart';
import '../../../firebase_options.dart';

final landingViewModelProvider =
    StateNotifierProvider<LandingViewModel, AsyncValue<void>>(
      (ref) => LandingViewModel(ref),
    );

class LandingViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  LandingViewModel(this.ref) : super(const AsyncValue.loading());

  Future<void> initializeApp() async {
    try {
      // Firebase Init
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Notifications Init
      await NotificationsService().init();

      // Subscribe to topic
      const topic = 'aquacare_alerts';
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }

      // Simulate other async work (like DB / SharedPrefs / API check)
      await Future.delayed(const Duration(seconds: 2));

      // Mark as loaded
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
