import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/aquarium/view/aquarium_dashboard_page.dart';
import 'firebase_options.dart';
import 'pages/Services/notif_service.dart'; // Make sure this file exists and is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM notifications
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await notificationService.requestNotificationPermission();
  notificationService.initFCM();

  // Subscribe to FCM topic for aquarium alerts
  await FirebaseMessaging.instance.subscribeToTopic('aquacare_alerts');

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
      home: const AquariumDashboardPage(),
    );
  }
}
