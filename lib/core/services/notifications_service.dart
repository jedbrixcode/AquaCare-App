// lib/core/services/notifications_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  Future<void> init({bool silentOnFailure = false}) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    try {
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // Check if Firebase is initialized before accessing FCM
      if (Firebase.apps.isNotEmpty) {
        // Try to access FirebaseMessaging - this might still throw if not fully initialized
        try {
          await FirebaseMessaging.instance.requestPermission();

          // Timezone init for zoned scheduling
          tz.initializeTimeZones();

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
        } catch (e) {
          // FirebaseMessaging not available - skip FCM setup
          debugPrint('FirebaseMessaging not available: $e');
          // Still initialize timezone
          tz.initializeTimeZones();
        }
      } else {
        // Firebase not initialized - skip FCM setup, but still initialize timezone
        tz.initializeTimeZones();
      }
    } catch (e) {
      if (!silentOnFailure) rethrow;
    }
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

  Future<void> scheduleLocal({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aquacare_alerts',
      'Aquacare Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _local.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _local.cancel(id);

  Future<void> cancelAllByIds(Iterable<int> ids) async {
    for (final i in ids) {
      await _local.cancel(i);
    }
  }
}
