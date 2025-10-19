import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:aquacare_v5/core/config/backend_config.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feeding_schedule_model.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';
import 'package:aquacare_v5/core/models/feeding_schedule_cache.dart';

class ScheduledAutofeedRepository {
  final String baseUrl = BackendConfig.flaskBaseUrl;

  // Simple in-memory cache placeholder. Swap with Hive/Prefs/Isar.
  final Map<String, List<FeedingSchedule>> _cache = {};

  // Get all feeding schedules for an aquarium (read from Firebase Realtime DB)
  Future<List<FeedingSchedule>> getFeedingSchedules(String aquariumId) async {
    try {
      final ref = FirebaseDatabase.instance.ref(
        'aquariums/$aquariumId/auto_feeder/schedule',
      );
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) {
        _cache[aquariumId] = const <FeedingSchedule>[];
        // clear local cache for this aquarium
        await LocalStorageService.instance.cacheFeedingSchedules(
          aquariumId,
          const <FeedingScheduleCache>[],
        );
        return const <FeedingSchedule>[];
      }
      final raw = Map<Object?, Object?>.from(snapshot.value as Map);
      final List<FeedingSchedule> items =
          raw.entries.map((entry) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              entry.value as Map,
            );
            data['id'] = entry.key.toString();
            data['aquarium_id'] = aquariumId;
            return FeedingSchedule.fromJson(data);
          }).toList();
      // Optional: sort by time ascending
      items.sort((a, b) => a.time.compareTo(b.time));
      _cache[aquariumId] = items;

      // persist to Isar
      await LocalStorageService.instance.cacheFeedingSchedules(
        aquariumId,
        items
            .map(
              (e) =>
                  FeedingScheduleCache()
                    ..aquariumId = aquariumId
                    ..scheduleId = e.id
                    ..time = e.time
                    ..cycles = e.cycles
                    ..foodType = e.foodType
                    ..isEnabled = e.isEnabled
                    ..daily = false,
            )
            .toList(),
      );
      return items;
    } catch (e) {
      // Fallback to local cache in Isar
      final cached = await LocalStorageService.instance.getFeedingSchedules(
        aquariumId,
      );
      if (cached.isNotEmpty) {
        return cached
            .map(
              (e) => FeedingSchedule(
                id: e.scheduleId,
                aquariumId: aquariumId,
                time: e.time,
                cycles: e.cycles,
                foodType: e.foodType,
                isEnabled: e.isEnabled,
                createdAt: DateTime.now(),
              ),
            )
            .toList()
          ..sort((a, b) => a.time.compareTo(b.time));
      }
      throw Exception('Error fetching feeding schedules: $e');
    }
  }

  // Add a new feeding schedule (Flask)
  Future<FeedingSchedule> addFeedingSchedule({
    required String aquariumId,
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
    bool daily = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_schedule/$aquariumId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'time': time,
          'cycle': cycles,
          'switch': isEnabled,
          'food': foodType,
          'daily': daily,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final created = FeedingSchedule.fromJson(data);
        final List<FeedingSchedule> list = [
          ...(_cache[aquariumId] ?? const <FeedingSchedule>[]),
          created,
        ];
        _cache[aquariumId] = list;
        return created;
      } else {
        throw Exception(
          'Failed to add feeding schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error adding feeding schedule: $e');
    }
  }

  // Update helpers (Flask)
  Future<void> updateCycle({
    required String aquariumId,
    required String time,
    required int cycles,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update_schedule_cycle/$aquariumId/$time/$cycles'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update cycle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cycle: $e');
    }
  }

  Future<void> updateSwitch({
    required String aquariumId,
    required String time,
    required bool isEnabled,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/update_schedule_switch/$aquariumId/$time/${isEnabled.toString()}',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update switch: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating switch: $e');
    }
  }

  Future<void> updateDaily({
    required String aquariumId,
    required String time,
    required bool daily,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/update_daily/$aquariumId/$time/${daily.toString()}',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update daily: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating daily: $e');
    }
  }

  // One-time task: add a single-run feeding via Flask + Firestore/APScheduler
  Future<void> addOneTimeTask({
    required String aquariumId,
    required DateTime scheduleDateTime,
    required int cycles,
    required String food,
  }) async {
    try {
      final payload = {
        'cycle': cycles,
        'schedule_time': _formatDateTime(scheduleDateTime),
        'food': food,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/task/$aquariumId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add one-time task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding one-time task: $e');
    }
  }

  // One-time task: delete by schedule_time string
  Future<void> deleteOneTimeTask({
    required String aquariumId,
    required DateTime scheduleDateTime,
  }) async {
    try {
      final scheduleTime = _formatDateTime(scheduleDateTime);
      final payload = {
        // Backend expects document_id formatted as f"{aquarium_id}_schedule_at_{schedule_time}"
        'document_id': '${aquariumId}_schedule_at_$scheduleTime',
      };
      final response = await http.post(
        Uri.parse('$baseUrl/task/delete/$aquariumId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete one-time task: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting one-time task: $e');
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatDateTime(DateTime dt) {
    // yyyy-MM-dd HH:mm:ss in server's local timezone
    final y = dt.year.toString().padLeft(4, '0');
    final M = _two(dt.month);
    final d = _two(dt.day);
    final h = _two(dt.hour);
    final m = _two(dt.minute);
    final s = _two(dt.second);
    return '$y-$M-$d $h:$m:$s';
  }

  // Delete a feeding schedule (by time)
  Future<void> deleteFeedingSchedule({
    required String aquariumId,
    required String scheduleId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_schedule/$aquariumId/$scheduleId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete feeding schedule: ${response.statusCode}',
        );
      }
      // Optimistically remove from cache
      final List<FeedingSchedule> list =
          (_cache[aquariumId] ?? const <FeedingSchedule>[])
              .where((e) => e.id != scheduleId)
              .toList();
      _cache[aquariumId] = list;
    } catch (e) {
      throw Exception('Error deleting feeding schedule: $e');
    }
  }

  // Toggle a feeding schedule enabled/disabled
  Future<void> toggleFeedingSchedule({
    required String aquariumId,
    required String scheduleId,
    required bool isEnabled,
  }) async {
    await updateSwitch(
      aquariumId: aquariumId,
      time: scheduleId,
      isEnabled: isEnabled,
    );
    final List<FeedingSchedule> list =
        (_cache[aquariumId] ?? const <FeedingSchedule>[])
            .map(
              (e) => e.id == scheduleId ? e.copyWith(isEnabled: isEnabled) : e,
            )
            .toList();
    _cache[aquariumId] = list;
  }

  // Get auto feeder status for an aquarium
  Future<AutoFeederStatus> getAutoFeederStatus(String aquariumId) async {
    try {
      // Compute status from Firebase schedules: enabled if any schedule.switch == true
      final ref = FirebaseDatabase.instance.ref(
        'aquariums/$aquariumId/auto_feeder/schedule',
      );
      final snapshot = await ref.get();
      bool enabled = false;
      if (snapshot.exists && snapshot.value != null) {
        final raw = Map<Object?, Object?>.from(snapshot.value as Map);
        for (final entry in raw.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if ((data['switch'] ?? false) == true) {
            enabled = true;
            break;
          }
        }
      }
      return AutoFeederStatus(
        aquariumId: aquariumId,
        isEnabled: enabled,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error fetching auto feeder status: $e');
    }
  }

  // Toggle auto feeder enabled/disabled
  Future<AutoFeederStatus> toggleAutoFeeder({
    required String aquariumId,
    required bool isEnabled,
  }) async {
    try {
      // Batch toggle all schedules' switch to the desired state using Flask route
      final ref = FirebaseDatabase.instance.ref(
        'aquariums/$aquariumId/auto_feeder/schedule',
      );
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final raw = Map<Object?, Object?>.from(snapshot.value as Map);
        final futures = <Future<void>>[];
        for (final entry in raw.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          final String time = (data['time'] ?? '').toString();
          if (time.isEmpty) continue;
          futures.add(
            updateSwitch(
              aquariumId: aquariumId,
              time: time,
              isEnabled: isEnabled,
            ),
          );
        }
        await Future.wait(futures);
      }
      return AutoFeederStatus(
        aquariumId: aquariumId,
        isEnabled: isEnabled,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error toggling auto feeder: $e');
    }
  }

  // Realtime subscriptions and caching APIs (stubs). Replace with Firebase/WS streams.
  Stream<List<FeedingSchedule>> subscribeSchedules(String aquariumId) {
    final ref = FirebaseDatabase.instance.ref(
      'aquariums/$aquariumId/auto_feeder/schedule',
    );
    return ref.onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) {
        _cache[aquariumId] = const <FeedingSchedule>[];
        return const <FeedingSchedule>[];
      }
      final raw = Map<Object?, Object?>.from(snapshot.value as Map);
      final List<FeedingSchedule> items =
          raw.entries.map((entry) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              entry.value as Map,
            );
            data['id'] = entry.key.toString();
            data['aquarium_id'] = aquariumId;
            return FeedingSchedule.fromJson(data);
          }).toList();
      items.sort((a, b) => a.time.compareTo(b.time));
      _cache[aquariumId] = items;
      // update local cache
      unawaited(
        LocalStorageService.instance.cacheFeedingSchedules(
          aquariumId,
          items
              .map(
                (e) =>
                    FeedingScheduleCache()
                      ..aquariumId = aquariumId
                      ..scheduleId = e.id
                      ..time = e.time
                      ..cycles = e.cycles
                      ..foodType = e.foodType
                      ..isEnabled = e.isEnabled
                      ..daily = false,
              )
              .toList(),
        ),
      );
      return items;
    });
  }

  Stream<AutoFeederStatus> subscribeAutoFeederStatus(String aquariumId) {
    final ref = FirebaseDatabase.instance.ref(
      'aquariums/$aquariumId/auto_feeder/schedule',
    );
    return ref.onValue.map((event) {
      bool enabled = false;
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        final raw = Map<Object?, Object?>.from(snapshot.value as Map);
        for (final entry in raw.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          if ((data['switch'] ?? false) == true) {
            enabled = true;
            break;
          }
        }
      }
      return AutoFeederStatus(
        aquariumId: aquariumId,
        isEnabled: enabled,
        lastUpdated: DateTime.now(),
      );
    });
  }

  Future<List<FeedingSchedule>?> getCachedSchedules(String aquariumId) async {
    final mem = _cache[aquariumId];
    if (mem != null) return mem;
    final cached = await LocalStorageService.instance.getFeedingSchedules(
      aquariumId,
    );
    if (cached.isEmpty) return null;
    return cached
        .map(
          (e) => FeedingSchedule(
            id: e.scheduleId,
            aquariumId: aquariumId,
            time: e.time,
            cycles: e.cycles,
            foodType: e.foodType,
            isEnabled: e.isEnabled,
            createdAt: DateTime.now(),
          ),
        )
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  Future<void> cacheSchedules(
    String aquariumId,
    List<FeedingSchedule> items,
  ) async {
    _cache[aquariumId] = items;
  }
}
