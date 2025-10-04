import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/navigation/route_observer.dart';
import 'firebase_options.dart';
import 'features/aquarium/view/aquarium_dashboard_page.dart';
import 'features/settings/viewmodel/theme_viewmodel.dart';
import 'features/landing/view/landing_page.dart';
import 'features/chat/view/chat_with_ai_page.dart';
import 'features/graphs/view/sensor_graphs_page.dart';
import 'features/settings/view/settings_page.dart';
import 'core/services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationsService().init();
  const topic = 'aquacare_alerts';
  try {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  } catch (_) {}

  // Subscribe to FCM topic for aquarium alerts
  try {
    // Wait a bit for FCM to initialize
    await Future.delayed(const Duration(seconds: 2));

    // Subscribe with simple backoff & only when token exists
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      const topic = 'aquacare_alerts';
      int attempt = 0;
      while (attempt < 5) {
        try {
          await FirebaseMessaging.instance.subscribeToTopic(topic);
          print("Subscribed to $topic");
          break;
        } catch (e) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 500 * (1 << attempt)));
        }
      }
    }
  } catch (e) {
    print("Error with FCM initialization: $e");
    // Don't let FCM errors prevent app startup
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaCare',
      theme: ThemeData.light(useMaterial3: false).copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      darkTheme: ThemeData.dark(useMaterial3: false),
      themeMode: themeMode,
      navigatorObservers: [appRouteObserver],
      home: const LandingPage(),
      routes: {
        '/chat': (context) => const AIChatPage(),
        '/graphs': (context) => const SensorGraphsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
