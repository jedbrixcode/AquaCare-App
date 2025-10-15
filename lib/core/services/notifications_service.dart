// lib/core/services/notifications_service.dart
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  static final NotificationsService _i = NotificationsService._();
  factory NotificationsService() => _i;
  NotificationsService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'aquacare_alerts',
    'Aquacare Alerts',
    description: 'Sensor alerts and app notifications',
    importance: Importance.high,
  );

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      // Only show manually if message does NOT have `notification` payload
      if (m.notification == null) {
        final data = m.data;
        showLocal(
          title: data['title'] ?? 'AquaCare',
          body: data['body'] ?? 'You have a new sensor alert.',
        );
      }
    });
  }

  void showRemoteMessage(RemoteMessage m) {
    final n = m.notification;
    if (n == null) return;
    showLocal(title: n.title ?? 'Aquacare', body: n.body ?? '');
  }

  Future<void> showLocal({required String title, required String body}) async {
    final id = Random().nextInt(1 << 31);
    const androidDetails = AndroidNotificationDetails(
      'aquacare_alerts',
      'Aquacare Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
