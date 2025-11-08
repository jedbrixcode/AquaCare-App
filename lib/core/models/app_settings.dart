import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;

  // Whether the device is subscribed to FCM topic(s)
  bool fcmSubscribed = false;

  // List of subscribed topics
  List<String> subscribedTopics = <String>[];

  // Theme preference if you choose to migrate from SharedPreferences
  String? themeMode; // 'light' | 'dark' | 'system'
}
