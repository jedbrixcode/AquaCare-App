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
  bool _isInitializing = false;
  bool _isInitialized = false;
  static Completer<void>? _globalInitCompleter;

  // Initialize Isar database once (thread-safe)
  Future<void> initialize() async {
    // If already initialized, return immediately
    if (_isInitialized) {
      try {
        _isar = Isar.getInstance()!;
        return;
      } catch (_) {
        // If getInstance fails, re-initialize
        _isInitialized = false;
      }
    }

    // Check if there's an existing instance
    final existing = Isar.getInstance();
    if (existing != null) {
      _isar = existing;
      _isInitialized = true;
      return;
    }

    // If another initialization is in progress, wait for it
    if (_isInitializing && _globalInitCompleter != null && !_globalInitCompleter!.isCompleted) {
      try {
        await _globalInitCompleter!.future;
        final instance = Isar.getInstance();
        if (instance != null) {
          _isar = instance;
          _isInitialized = true;
          return;
        }
      } catch (_) {
        // If the previous initialization failed, we'll try again
        _globalInitCompleter = null;
        _isInitializing = false;
      }
    }

    // Start new initialization - set flag and create completer
    _isInitializing = true;
    _globalInitCompleter = Completer<void>();

    try {
      final dir = await getApplicationDocumentsDirectory();

      int retries = 0;
      const maxRetries = 20; // Increased retries
      Duration retryDelay = const Duration(milliseconds: 100);

      while (retries < maxRetries) {
        try {
          // Double-check for existing instance before opening
          final existingCheck = Isar.getInstance();
          if (existingCheck != null) {
            _isar = existingCheck;
            _isInitialized = true;
            _globalInitCompleter?.complete();
            return;
          }

          _isar = await Isar.open([
            LatestSensorSchema,
            HourlyLogSchema,
            AverageLogSchema,
            AppSettingsSchema,
            ChatMessageIsarSchema,
            FeedingScheduleCacheSchema,
            OneTimeScheduleCacheSchema,
          ], directory: dir.path);
          
          _isInitialized = true;
          _globalInitCompleter?.complete();
          return; // ✅ Successfully opened
        } catch (e) {
          final errorStr = e.toString();
          if (errorStr.contains('MdbxError (11)') && retries < maxRetries - 1) {
            retries++;
            // Exponential backoff: 100ms, 200ms, 400ms, 800ms, etc. (max 2 seconds)
            retryDelay = Duration(
              milliseconds: (100 * (1 << retries.clamp(0, 4))).clamp(100, 2000),
            );
            await Future.delayed(retryDelay);
          } else {
            _isInitializing = false;
            _globalInitCompleter?.completeError(e);
            _globalInitCompleter = null;
            rethrow;
          }
        }
      }
      
      _isInitializing = false;
      _globalInitCompleter?.completeError(
        Exception('Failed to open Isar database after $maxRetries retries'),
      );
      _globalInitCompleter = null;
      throw Exception('Failed to open Isar database after $maxRetries retries');
    } catch (e) {
      _isInitializing = false;
      _globalInitCompleter?.completeError(e);
      _globalInitCompleter = null;
      rethrow;
    }
  }

  // Cache latest sensor values per aquarium
  Future<void> cacheLatestSensors({
    required String aquariumId,
    required double temperature,
    required double ph,
    required double turbidity,
    required int timestampMs,
    String? name,
  }) async {
    // Get existing entry to preserve name if not provided
    final existing = await _isar.latestSensors
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByTimestampMsDesc()
        .findFirst();
    
    final entry =
        LatestSensor()
          ..aquariumId = aquariumId
          ..temperature = temperature
          ..ph = ph
          ..turbidity = turbidity
          ..timestampMs = timestampMs
          ..name = name ?? existing?.name;

    await _isar.writeTxn(() async {
      await _isar.latestSensors.put(entry);
    });
  }

  // Cache aquarium name
  Future<void> cacheAquariumName(String aquariumId, String name) async {
    final existing = await _isar.latestSensors
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByTimestampMsDesc()
        .findFirst();
    
    if (existing != null) {
      existing.name = name;
      await _isar.writeTxn(() async {
        await _isar.latestSensors.put(existing);
      });
    } else {
      // Create a minimal entry with just the name
      final entry = LatestSensor()
        ..aquariumId = aquariumId
        ..temperature = 0
        ..ph = 0
        ..turbidity = 0
        ..timestampMs = DateTime.now().millisecondsSinceEpoch
        ..name = name;
      await _isar.writeTxn(() async {
        await _isar.latestSensors.put(entry);
      });
    }
  }

  // Get aquarium name from cache
  Future<String?> getAquariumName(String aquariumId) async {
    final entry = await _isar.latestSensors
        .filter()
        .aquariumIdEqualTo(aquariumId)
        .sortByTimestampMsDesc()
        .findFirst();
    return entry?.name;
  }

  // Delete all aquarium data from local DB using aquarium ID as reference
  Future<void> deleteAquariumData(String aquariumId) async {
    await _isar.writeTxn(() async {
      // Delete latest sensors for this aquarium
      await _isar.latestSensors
          .filter()
          .aquariumIdEqualTo(aquariumId)
          .deleteAll();
      
      // Delete hourly logs for this aquarium
      await _isar.hourlyLogs
          .filter()
          .aquariumIdEqualTo(aquariumId)
          .deleteAll();
      
      // Delete average logs for this aquarium
      await _isar.averageLogs
          .filter()
          .aquariumIdEqualTo(aquariumId)
          .deleteAll();
      
      // Delete feeding schedules for this aquarium
      await _isar.feedingScheduleCaches
          .filter()
          .aquariumIdEqualTo(aquariumId)
          .deleteAll();
      
      // Delete one-time schedules for this aquarium
      await _isar.oneTimeScheduleCaches
          .filter()
          .aquariumIdEqualTo(aquariumId)
          .deleteAll();
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
      'name': data.name,
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
            'name': e.name,
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
