import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:aquacare_v5/pages/Services/notif_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:aquacare_v5/pages/Services/websocket_service.dart';

import 'package:aquacare_v5/pages/autofeed_page.dart';
import 'package:aquacare_v5/pages/autolight_page.dart';
import 'package:aquacare_v5/pages/home_page.dart';
import 'package:aquacare_v5/pages/landing_page.dart';
import 'package:aquacare_v5/pages/phlevel_page.dart';
import 'package:aquacare_v5/pages/temperature_page.dart';
import 'package:aquacare_v5/pages/waterturbidity_page.dart';
import 'dart:async';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(' Background Message: ${message.messageId}');
  NotificationService().showNotification(
    title: message.notification?.title ?? 'Alert',
    body: message.notification?.body ?? '',
    payLoad: 'Background Payload',
  );
}

Future<void> main() async {
  // Wrap with zone to catch all uncaught errors
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        name: 'aquamans-47d16',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Call notification method
      final notifService = NotificationService();
      await notifService.requestNotificationPermission();
      await notifService.initNotification();
      notifService.initFCM();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic('sensor_alerts');

      String? token = await messaging.getToken();
      print("FCM Token: $token");

      // WebSocketService().connect(
      //   onNotificationReceived: (type, message) {
      //     print("[$type Notification] $message");

      //     // Trigger notification for temperature alerts
      //     if (type == "Temperature") {
      //       NotificationService().showNotification(
      //         title: 'Temperature Alert!',
      //         body: message,
      //         payLoad: 'Temperature alert triggered',
      //       );
      //     }
      //   },
      // );

      runApp(const MyApp());
    },
    (error, stackTrace) {
      print("Uncaught Error: $error");
      print("Stack Trace: $stackTrace");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/landing',
      debugShowCheckedModeBanner: false,
      routes: {
        '/landing': (context) => LandingPage(),
        '/homepage': (context) => HomePage(),
        '/temperature': (context) => TemperaturePage(),
        '/waterturbidity': (context) => WaterTurbidityPage(),
        '/food': (context) => AutoFeedingPage(),
        '/light': (context) => AutoLightPage(),
        '/phlevel': (context) => PhlevelPage(),
      },
    );
  }
}
