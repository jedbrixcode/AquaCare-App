import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../models/latest_sensor.dart';
import '../models/hourly_log.dart';
import '../models/average_log.dart';
import '../models/app_settings.dart';
import '../models/chat_message_isar.dart';
import '../models/feeding_schedule_cache.dart';
import '../models/one_time_schedule_cache.dart';

class LocalStorageService {
  LocalStorageService._private();
  static final LocalStorageService instance = LocalStorageService._private();

  late Isar _isar;

  // Initialize Isar database once
  Future<void> initialize() async {
    final existing = Isar.getInstance();
    if (existing != null) {
      _isar = existing;
      return;
    }
    final dir = await getApplicationDocumentsDirectory();

    int retries = 0;
    const maxRetries = 10;
    const retryDelay = Duration(milliseconds: 100);
    while (retries < maxRetries) {
      try {
        _isar = await Isar.open([
          LatestSensorSchema,
          HourlyLogSchema,
          AverageLogSchema,
          AppSettingsSchema,
          ChatMessageIsarSchema,
          FeedingScheduleCacheSchema,
          OneTimeScheduleCacheSchema,
        ], directory: dir.path);
        return; // ✅ Successfully opened
      } catch (e) {
        if (e.toString().contains('MdbxError (11)') &&
            retries < maxRetries - 1) {
          retries++;
          await Future.delayed(retryDelay);
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Failed to open Isar database after $maxRetries retries');
  }

  // Cache latest sensor values per aquarium
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

  // Cache hourly logs
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

  // Cache daily/weekly averages
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

  // Readers
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

  // Get latest sensor snapshot for ALL aquariums (dedup by newest timestamp)
  Future<List<Map<String, dynamic>>> getAllLatestSensorsLatest() async {
    final all = await _isar.latestSensors.where().findAll();
    final Map<String, LatestSensor> newestByAquariumId = {};
    for (final entry in all) {
      final existing = newestByAquariumId[entry.aquariumId];
      if (existing == null || (entry.timestampMs) > (existing.timestampMs)) {
        newestByAquariumId[entry.aquariumId] = entry;
      }
    }
    return newestByAquariumId.values
        .map(
          (e) => {
            'aquariumId': e.aquariumId,
            'temperature': e.temperature,
            'ph': e.ph,
            'turbidity': e.turbidity,
            'timestampMs': e.timestampMs,
          },
        )
        .toList();
  }

  // Reactive watcher for any latest sensor change across all aquariums
  Stream<void> watchAllLatestSensorsLazy() {
    return _isar.latestSensors.watchLazy();
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

  // App Settings
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

  // Chat Persistence
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

  // Scheduled Autofeed Cache
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

  // One-time schedules cache (Firestore mirror)
  Future<void> cacheOneTimeSchedules(
    String aquariumId,
    List<OneTimeScheduleCache> items,
  ) async {
    await _isar.writeTxn(() async {
      final old =
          await _isar.oneTimeScheduleCaches
              .filter()
              .aquariumIdEqualTo(aquariumId)
              .findAll();
      if (old.isNotEmpty) {
        await _isar.oneTimeScheduleCaches.deleteAll(
          old.map((e) => e.id).toList(),
        );
      }
      await _isar.oneTimeScheduleCaches.putAll(items);
    });
  }

  Future<List<OneTimeScheduleCache>> getOneTimeSchedules(
    String aquariumId,
  ) async {
    return _isar.oneTimeScheduleCaches
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByScheduleTime()
        .findAll();
  }

  Stream<List<OneTimeScheduleCache>> watchOneTimeSchedules(String aquariumId) {
    return _isar.oneTimeScheduleCaches
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByScheduleTime()
        .watch(fireImmediately: true);
  }
}
