import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/landing_page.dart';
import 'firebase_options.dart';
import 'pages/Services/notif_service.dart';

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

    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    if (token != null) {
      await FirebaseMessaging.instance.subscribeToTopic('aquacare_alerts');
      print("Successfully subscribed to aquacare_alerts topic");
    } else {
      print("No FCM token available yet, will retry later");
    }
  } catch (e) {
    print("Error with FCM initialization: $e");
    // Don't let FCM errors prevent app startup
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaCare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LandingPage(),
    );
  }
}
