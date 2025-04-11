import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // Android-specific initialization settings
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/aquacarelogo');

    // iOS-specific initialization settings
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // General initialization settings for both platforms
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle the notification response here
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
        // You can also perform navigation or other actions here
      },
    );
  }

  void initFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground Message Received: ${message.notification?.title}');
      showNotification(
        title: message.notification?.title ?? 'FCM Alert',
        body: message.notification?.body ?? '',
        payLoad: 'Foreground Payload',
      );
    });
  }

  // Method to create NotificationDetails
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId', // channel ID
        'channelName', // channel name
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Method to show a notification
  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return notificationPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
      payload: payLoad,
    );
  }

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      // iOS-specific permission request
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      // Android 13+ needs this
      NotificationSettings settings = await messaging.requestPermission();
      print(
        '🛡️ Android Notification Permission: ${settings.authorizationStatus}',
      );
    }
  }
}
