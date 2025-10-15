import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../models/latest_sensor.dart';
import '../models/hourly_log.dart';
import '../models/average_log.dart';
import '../models/app_settings.dart';
import '../models/chat_message_isar.dart';
import '../models/feeding_schedule_cache.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late Isar _isar;

  // Initialize Isar database once
  Future<void> initialize() async {
    final existing = Isar.getInstance();
    if (existing != null) {
      _isar = existing;
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      LatestSensorSchema,
      HourlyLogSchema,
      AverageLogSchema,
      AppSettingsSchema,
      ChatMessageIsarSchema,
      FeedingScheduleCacheSchema,
    ], directory: dir.path);
  }

  // ✅ Cache latest sensor values per aquarium
  Future<void> cacheLatestSensors({
    required String aquariumId,
    required double temperature,
    required double ph,
    required double turbidity,
    required int timestampMs,
  }) async {
    final entry =
        LatestSensor()
          ..aquariumId = aquariumId
          ..temperature = temperature
          ..ph = ph
          ..turbidity = turbidity
          ..timestampMs = timestampMs;

    await _isar.writeTxn(() async {
      await _isar.latestSensors.put(entry);
    });
  }

  // ✅ Cache hourly logs
  Future<void> cacheHourlyLog({
    required String aquariumId,
    required int hourIndex,
    required double temperature,
    required double ph,
    required double turbidity,
  }) async {
    final entry =
        HourlyLog()
          ..aquariumId = aquariumId
          ..hourIndex = hourIndex
          ..temperature = temperature
          ..ph = ph
          ..turbidity = turbidity;

    await _isar.writeTxn(() async {
      await _isar.hourlyLogs.put(entry);
    });
  }

  // ✅ Cache daily/weekly averages
  Future<void> cacheAverage({
    required String aquariumId,
    required int dayIndex,
    required double temperature,
    required double ph,
    required double turbidity,
  }) async {
    final entry =
        AverageLog()
          ..aquariumId = aquariumId
          ..dayIndex = dayIndex
          ..temperature = temperature
          ..ph = ph
          ..turbidity = turbidity;

    await _isar.writeTxn(() async {
      await _isar.averageLogs.put(entry);
    });
  }

  // ✅ Readers
  Future<Map<String, dynamic>?> getLatestSensors(String aquariumId) async {
    final data =
        await _isar.latestSensors
            .filter()
            .aquariumIdEqualTo(aquariumId)
            .sortByTimestampMsDesc()
            .findFirst();

    if (data == null) return null;

    return {
      'aquariumId': data.aquariumId,
      'temperature': data.temperature,
      'ph': data.ph,
      'turbidity': data.turbidity,
      'timestampMs': data.timestampMs,
    };
  }

  // Reactive watcher for latest sensors per aquarium
  Stream<void> watchLatestSensorsLazy(String aquariumId) {
    return _isar.latestSensors
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .watchLazy();
  }

  Future<List<Map<String, dynamic>>> getHourlyLogs(String aquariumId) async {
    final results =
        await _isar.hourlyLogs.filter().aquariumIdEqualTo(aquariumId).findAll();

    return results
        .map(
          (e) => {
            'aquariumId': e.aquariumId,
            'hourIndex': e.hourIndex,
            'temperature': e.temperature,
            'ph': e.ph,
            'turbidity': e.turbidity,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAverages(String aquariumId) async {
    final results =
        await _isar.averageLogs
            .filter()
            .aquariumIdEqualTo(aquariumId)
            .findAll();

    return results
        .map(
          (e) => {
            'aquariumId': e.aquariumId,
            'dayIndex': e.dayIndex,
            'temperature': e.temperature,
            'ph': e.ph,
            'turbidity': e.turbidity,
          },
        )
        .toList();
  }

  // -----------------
  // App Settings
  // -----------------
  Future<String?> getThemeModeString() async {
    final s = await _isar.appSettings.where().findFirst();
    return s?.themeMode;
  }

  Future<void> setThemeModeString(String value) async {
    await _isar.writeTxn(() async {
      final settings =
          await _isar.appSettings.where().findFirst() ?? AppSettings();
      settings.themeMode = value;
      await _isar.appSettings.put(settings);
    });
  }

  Future<void> setFcmSubscribed(bool value) async {
    await _isar.writeTxn(() async {
      final settings =
          await _isar.appSettings.where().findFirst() ?? AppSettings();
      settings.fcmSubscribed = value;
      await _isar.appSettings.put(settings);
    });
  }

  Future<bool> getFcmSubscribed() async {
    final s = await _isar.appSettings.where().findFirst();
    return s?.fcmSubscribed ?? false;
  }

  Future<void> upsertSubscribedTopics(List<String> topics) async {
    await _isar.writeTxn(() async {
      final settings =
          await _isar.appSettings.where().findFirst() ?? AppSettings();
      settings.subscribedTopics = topics;
      await _isar.appSettings.put(settings);
    });
  }

  Future<List<String>> getSubscribedTopics() async {
    final s = await _isar.appSettings.where().findFirst();
    return s?.subscribedTopics ?? <String>[];
  }

  Stream<void> watchSettingsLazy() => _isar.appSettings.watchLazy();

  // -----------------
  // Chat Persistence
  // -----------------
  Future<void> addChatMessage(ChatMessageIsar msg) async {
    await _isar.writeTxn(() async {
      await _isar.chatMessageIsars.put(msg);
    });
  }

  Future<List<ChatMessageIsar>> getChatMessages() async {
    return _isar.chatMessageIsars.where().sortByTimestamp().findAll();
  }

  Future<void> clearChatMessages() async {
    await _isar.writeTxn(() async {
      await _isar.chatMessageIsars.where().deleteAll();
    });
  }

  Stream<List<ChatMessageIsar>> watchChatMessages() {
    return _isar.chatMessageIsars.where().watch(fireImmediately: true);
  }

  // -----------------
  // Scheduled Autofeed Cache
  // -----------------
  Future<void> cacheFeedingSchedules(
    String aquariumId,
    List<FeedingScheduleCache> items,
  ) async {
    await _isar.writeTxn(() async {
      final old =
          await _isar.feedingScheduleCaches
              .filter()
              .aquariumIdEqualTo(aquariumId)
              .findAll();
      if (old.isNotEmpty) {
        await _isar.feedingScheduleCaches.deleteAll(
          old.map((e) => e.id).toList(),
        );
      }
      await _isar.feedingScheduleCaches.putAll(items);
    });
  }

  Future<List<FeedingScheduleCache>> getFeedingSchedules(
    String aquariumId,
  ) async {
    return _isar.feedingScheduleCaches
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByTime()
        .findAll();
  }

  Stream<List<FeedingScheduleCache>> watchFeedingSchedules(String aquariumId) {
    return _isar.feedingScheduleCaches
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByTime()
        .watch(fireImmediately: true);
  }
}
