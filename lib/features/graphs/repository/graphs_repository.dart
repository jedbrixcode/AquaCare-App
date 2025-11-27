import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:aquacare_v5/core/models/sensor_log_point.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';

class GraphsRepository {
  DatabaseReference? _dbRef() {
    try {
      // Returns null if Firebase is not yet initialized (offline-first mode)
      Firebase.app();
      return FirebaseDatabase.instance.ref();
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> fetchAquariumNames() async {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: get names from local cache
      final cached = await LocalStorageService.instance.getAllLatestSensorsLatest();
      return cached
          .map((e) => (e['name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    }
    
    try {
      final snapshot = await db.child('aquariums').get();
      final List<String> names = [];

      if (snapshot.exists) {
        for (final aquarium in snapshot.children) {
          final data = aquarium.value as Map?;
          final name = data?['name']?.toString();
          if (name != null && name.isNotEmpty) {
            names.add(name);
            // Cache the name
            final aquariumId = aquarium.key;
            if (aquariumId != null) {
              unawaited(
                LocalStorageService.instance.cacheAquariumName(
                  aquariumId.toString(),
                  name,
                ),
              );
            }
          }
        }
      }

      return names;
    } catch (_) {
      // Fallback to cached names
      final cached = await LocalStorageService.instance.getAllLatestSensorsLatest();
      return cached
          .map((e) => (e['name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    }
  }

  Future<Map<String, String>> fetchAquariumIdNameMap() async {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: get from local cache
      final cached = await LocalStorageService.instance.getAllLatestSensorsLatest();
      final Map<String, String> map = {};
      for (final e in cached) {
        final id = (e['aquariumId'] ?? '').toString();
        final name = (e['name'] ?? '').toString();
        if (id.isNotEmpty && name.isNotEmpty) {
          map[name] = id;
        }
      }
      return map;
    }
    
    try {
      final snapshot = await db.child('aquariums').get();
      final Map<String, String> map = {};

      if (snapshot.exists) {
        for (final aquarium in snapshot.children) {
          final data = aquarium.value as Map?;
          final id = aquarium.key; // Firebase node key
          final name = data?['name']?.toString();
          if (id != null && name != null && name.isNotEmpty) {
            map[name] = id;
            // Cache the name
            unawaited(
              LocalStorageService.instance.cacheAquariumName(id, name),
            );
          }
        }
      }

      return map;
    } catch (_) {
      // Fallback to cached
      final cached = await LocalStorageService.instance.getAllLatestSensorsLatest();
      final Map<String, String> map = {};
      for (final e in cached) {
        final id = (e['aquariumId'] ?? '').toString();
        final name = (e['name'] ?? '').toString();
        if (id.isNotEmpty && name.isNotEmpty) {
          map[name] = id;
        }
      }
      return map;
    }
  }

  Stream<List<String>> fetchAquariumNamesStream() {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: return cached names as a stream
      return Stream.fromFuture(
        LocalStorageService.instance.getAllLatestSensorsLatest().then((cached) {
          return cached
              .map((e) => (e['name'] ?? '').toString())
              .where((name) => name.isNotEmpty)
              .toList();
        }),
      );
    }
    
    return db.child('aquariums').onValue.map((event) {
      final List<String> names = [];
      if (!event.snapshot.exists) return names;

      for (final aquarium in event.snapshot.children) {
        final data = aquarium.value as Map?;
        final name = data?['name']?.toString();
        final id = aquarium.key;
        if (name != null && name.isNotEmpty) {
          names.add(name);
          // Cache the name
          if (id != null) {
            unawaited(
              LocalStorageService.instance.cacheAquariumName(id, name),
            );
          }
        }
      }
      return names;
    }).handleError((error) {
      // On error, return cached names
      return LocalStorageService.instance.getAllLatestSensorsLatest().then((cached) {
        return cached
            .map((e) => (e['name'] ?? '').toString())
            .where((name) => name.isNotEmpty)
            .toList();
      });
    });
  }

  /// Fetch hourly (daily) sensor readings for a specific aquarium
  Future<List<SensorLogPoint>> fetchDaily(
    String sensorType,
    String aquariumId,
  ) async {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: use cached data
      final logs = await LocalStorageService.instance.getHourlyLogs(aquariumId);
      final lower = sensorType.toLowerCase();
      final List<SensorLogPoint> points =
          logs.map((e) {
              final v = (e[lower] ?? 0).toDouble();
              return SensorLogPoint(
                value: v,
                time: DateTime(
                  0,
                ).add(Duration(hours: (e['hourIndex'] ?? 0) as int)),
                label: sensorType,
              );
            }).toList()
            ..sort((a, b) => a.time.hour.compareTo(b.time.hour));
      return points;
    }
    
    try {
      final snapshot =
          await db.child('aquariums/$aquariumId/hourly_log').get();
      final List<SensorLogPoint> points = [];
      if (snapshot.exists) {
        for (final entry in snapshot.children) {
          final key = int.tryParse(entry.key ?? '');
          if (key == null) continue;
          final raw = entry.value;
          if (raw is! Map) continue;
          final data = Map<String, dynamic>.from(raw);
          final value = double.tryParse(
            data[sensorType.toLowerCase()]?.toString() ?? '',
          );
          if (value == null) continue;
          points.add(
            SensorLogPoint(
              value: value,
              time: DateTime(0).add(Duration(hours: key)),
              label: sensorType,
            ),
          );

          // cache locally
          await LocalStorageService.instance.cacheHourlyLog(
            aquariumId: aquariumId,
            hourIndex: key,
            temperature: sensorType.toLowerCase() == 'temperature' ? value : 0,
            ph: sensorType.toLowerCase() == 'ph' ? value : 0,
            turbidity: sensorType.toLowerCase() == 'turbidity' ? value : 0,
          );
        }
      }
      points.sort((a, b) => a.time.hour.compareTo(b.time.hour));
      return points;
    } catch (_) {
      // fallback to cached
      final logs = await LocalStorageService.instance.getHourlyLogs(aquariumId);
      final lower = sensorType.toLowerCase();
      final List<SensorLogPoint> points =
          logs.map((e) {
              final v = (e[lower] ?? 0).toDouble();
              return SensorLogPoint(
                value: v,
                time: DateTime(
                  0,
                ).add(Duration(hours: (e['hourIndex'] ?? 0) as int)),
                label: sensorType,
              );
            }).toList()
            ..sort((a, b) => a.time.hour.compareTo(b.time.hour));
      return points;
    }
  }

  /// Fetch weekly averages for a specific aquarium
  Future<List<SensorLogPoint>> fetchWeeklyAverages(String aquariumId) async {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: use cached data
      final avgs = await LocalStorageService.instance.getAverages(aquariumId);
      final now = DateTime.now();
      final points = <SensorLogPoint>[];
      for (int i = 0; i < avgs.length; i++) {
        final rec = avgs[i];
        final time = now.subtract(Duration(days: avgs.length - 1 - i));
        points.add(
          SensorLogPoint(
            value: (rec['ph'] ?? 0).toDouble(),
            time: time,
            label: 'PH',
          ),
        );
        points.add(
          SensorLogPoint(
            value: (rec['temperature'] ?? 0).toDouble(),
            time: time,
            label: 'Temperature',
          ),
        );
        points.add(
          SensorLogPoint(
            value: (rec['turbidity'] ?? 0).toDouble(),
            time: time,
            label: 'Turbidity',
          ),
        );
      }
      return points;
    }
    
    try {
      final snapshot = await db.child('aquariums/$aquariumId/average').get();
      if (!snapshot.exists) return [];

      final List<SensorLogPoint> points = [];
      final value = snapshot.value;
      if (value is! Map) return [];
      final map = Map<String, dynamic>.from(value);

      final entries =
          map.entries
              .where((e) => e.key != 'index')
              .where((e) => int.tryParse(e.key) != null)
              .toList()
            ..sort((a, b) => (int.parse(a.key)).compareTo(int.parse(b.key)));

      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        final record = e.value;
        if (record is! Map) continue;
        final rec = Map<String, dynamic>.from(record);

        final ph = rec['ph'];
        final temp = rec['temperature'];
        final turb = rec['turbidity'];

        final time = DateTime.now().subtract(
          Duration(days: entries.length - 1 - i),
        );

        if (ph is num) {
          points.add(
            SensorLogPoint(value: ph.toDouble(), time: time, label: 'PH'),
          );
        }
        if (temp is num) {
          points.add(
            SensorLogPoint(
              value: temp.toDouble(),
              time: time,
              label: 'Temperature',
            ),
          );
        }
        if (turb is num) {
          points.add(
            SensorLogPoint(
              value: turb.toDouble(),
              time: time,
              label: 'Turbidity',
            ),
          );
        }

        // cache locally
        await LocalStorageService.instance.cacheAverage(
          aquariumId: aquariumId,
          dayIndex: i,
          temperature: (temp is num) ? temp.toDouble() : 0,
          ph: (ph is num) ? ph.toDouble() : 0,
          turbidity: (turb is num) ? turb.toDouble() : 0,
        );
      }
      return points;
    } catch (_) {
      final avgs = await LocalStorageService.instance.getAverages(aquariumId);
      final now = DateTime.now();
      final points = <SensorLogPoint>[];
      for (int i = 0; i < avgs.length; i++) {
        final rec = avgs[i];
        final time = now.subtract(Duration(days: avgs.length - 1 - i));
        points.add(
          SensorLogPoint(
            value: (rec['ph'] ?? 0).toDouble(),
            time: time,
            label: 'PH',
          ),
        );
        points.add(
          SensorLogPoint(
            value: (rec['temperature'] ?? 0).toDouble(),
            time: time,
            label: 'Temperature',
          ),
        );
        points.add(
          SensorLogPoint(
            value: (rec['turbidity'] ?? 0).toDouble(),
            time: time,
            label: 'Turbidity',
          ),
        );
      }
      return points;
    }
  }
}

final graphsRepositoryProvider = Provider<GraphsRepository>((ref) {
  return GraphsRepository();
});
