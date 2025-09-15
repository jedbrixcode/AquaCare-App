import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/landing_page.dart';
import 'package:flutter/widgets.dart';
import 'core/navigation/route_observer.dart';
import 'firebase_options.dart';
import 'pages/Services/notif_service.dart';
import 'features/settings/viewmodel/theme_viewmodel.dart';
import 'pages/chatwithAI_page.dart';
import 'pages/sensorgraphs_page.dart';
import 'features/settings/view/settings_page.dart';

// Route observer is provided from core/navigation/route_observer.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM notifications
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await notificationService.requestNotificationPermission();
  notificationService.initFCM();

  // Subscribe to FCM topic for aquarium alerts
  try {
    // Wait a bit for FCM to initialize
    await Future.delayed(const Duration(seconds: 2));

    // Subscribe with simple backoff & only when token exists
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
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
    } else {
      print("No FCM token available yet, will retry later");
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
