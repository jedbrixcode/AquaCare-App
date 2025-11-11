import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';
import 'package:flutter/material.dart' hide Threshold;
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class AquariumSummary {
  final String aquariumId;
  final String name;
  final Sensor sensor;

  AquariumSummary({
    required this.aquariumId,
    required this.name,
    required this.sensor,
  });
}

class AquariumRepository {
  DatabaseReference? _dbRef() {
    try {
      // Returns null if Firebase is not yet initialized (offline-first mode)
      Firebase.app();
      return FirebaseDatabase.instance.ref();
    } catch (_) {
      return null;
    }
  }

  // Get all aquarium IDs from the database (supports both Map and List structures)
  Stream<List<String>> getAllAquariumIds() {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: derive IDs from cached latest sensor entries
      return Stream.fromFuture(
        LocalStorageService.instance.getAllLatestSensorsLatest().then((list) {
          final ids = <String>{};
          for (final e in list) {
            final id = (e['aquariumId'] ?? '').toString();
            if (id.isNotEmpty) ids.add(id);
          }
          return ids.toList();
        }),
      );
    }
    return db.child('aquariums').onValue.map((event) {
      final dynamic data = event.snapshot.value;
      if (data == null) return <String>[];

      if (data is Map) {
        return data.keys.cast<String>().toList();
      }
      if (data is List) {
        final List<String> ids = [];
        for (final item in data) {
          if (item is Map) {
            final String? id = (item['aquarium_id'] ?? item['id'])?.toString();
            if (id != null && id.isNotEmpty) ids.add(id);
          }
        }
        return ids;
      }
      return <String>[];
    });
  }

  // Get sensor data for a specific aquarium by id (index path still works for list-backed RTDB)
  Stream<Sensor> sensorStream(String aquariumId) {
    final db = _dbRef();
    if (db == null) {
      // Offline fallback: emit cached latest if available, otherwise zeros
      return Stream.fromFuture(
        LocalStorageService.instance.getAllLatestSensorsLatest().then((list) {
          Sensor? cached;
          for (final e in list) {
            if ((e['aquariumId'] ?? '').toString() == aquariumId) {
              cached = Sensor(
                temperature: (e['temperature'] ?? 0).toDouble(),
                turbidity: (e['turbidity'] ?? 0).toDouble(),
                ph: (e['ph'] ?? 0).toDouble(),
              );
              break;
            }
          }
          return cached ?? Sensor(temperature: 0, turbidity: 0, ph: 0);
        }),
      );
    }
    return db
        .child('aquariums/$aquariumId/sensors')
        .onValue
        .map((event) {
          try {
            final data = event.snapshot.value as Map?;
            if (data == null) {
              return Sensor(temperature: 0, turbidity: 0, ph: 0);
            }
            final sensor = Sensor(
              temperature: (data['temperature'] ?? 0).toDouble(),
              turbidity: (data['turbidity'] ?? 0).toDouble(),
              ph: (data['ph'] ?? 0).toDouble(),
            );
            // cache latest for offline
            unawaited(
              LocalStorageService.instance.cacheLatestSensors(
                aquariumId: aquariumId,
                temperature: sensor.temperature,
                ph: sensor.ph,
                turbidity: sensor.turbidity,
                timestampMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
            return sensor;
          } catch (e) {
            debugPrint(
              'Error processing sensor data for aquarium $aquariumId: $e',
            );
            return Sensor(temperature: 0, turbidity: 0, ph: 0);
          }
        })
        .handleError((error) {
          debugPrint(
            'Firebase error in sensorStream for aquarium $aquariumId: $error',
          );
          return Sensor(temperature: 0, turbidity: 0, ph: 0);
        });
  }

  // Stream of all aquariums with name and sensors, offline-first (emit cached immediately)
  Stream<List<AquariumSummary>> getAllAquariumsSummary() {
    final cached$ = Stream.fromFuture(
      LocalStorageService.instance.getAllLatestSensorsLatest().then((list) {
        return list
            .map(
              (e) => AquariumSummary(
                aquariumId: (e['aquariumId'] ?? '').toString(),
                name: '', // name is unknown from cache; UI can fallback
                sensor: Sensor(
                  temperature: (e['temperature'] ?? 0).toDouble(),
                  turbidity: (e['turbidity'] ?? 0).toDouble(),
                  ph: (e['ph'] ?? 0).toDouble(),
                ),
              ),
            )
            .toList();
      }),
    );

    final db = _dbRef();
    Stream<List<AquariumSummary>> live$;
    if (db == null) {
      // Offline: no live Firebase stream
      live$ = const Stream.empty();
    } else {
      live$ = db
          .child('aquariums')
          .onValue
          .map((event) {
            try {
              final dynamic data = event.snapshot.value;
              final List<AquariumSummary> result = [];
              if (data == null) return result;

              if (data is Map) {
                data.forEach((key, value) {
                  try {
                    if (value is Map && value.isNotEmpty) {
                      final sensors = value['sensors'] as Map?;
                      final name = (value['name'] ?? 'New Aquarium').toString();
                      if (sensors != null && sensors.isNotEmpty) {
                        result.add(
                          AquariumSummary(
                            aquariumId: key.toString(),
                            name: name,
                            sensor: Sensor(
                              temperature:
                                  (sensors['temperature'] ?? 0).toDouble(),
                              turbidity: (sensors['turbidity'] ?? 0).toDouble(),
                              ph: (sensors['ph'] ?? 0).toDouble(),
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error processing aquarium $key: $e');
                  }
                });
                return result;
              }

              if (data is List) {
                for (final item in data) {
                  try {
                    if (item is Map && item.isNotEmpty) {
                      final String id =
                          (item['aquarium_id'] ?? item['id'] ?? '').toString();
                      if (id.isEmpty) continue;
                      final String name =
                          (item['name'] ?? 'New Aquarium').toString();
                      final sensors = item['sensors'] as Map?;
                      if (sensors != null && sensors.isNotEmpty) {
                        result.add(
                          AquariumSummary(
                            aquariumId: id,
                            name: name,
                            sensor: Sensor(
                              temperature:
                                  (sensors['temperature'] ?? 0).toDouble(),
                              turbidity: (sensors['turbidity'] ?? 0).toDouble(),
                              ph: (sensors['ph'] ?? 0).toDouble(),
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error processing aquarium item: $e');
                  }
                }
                return result;
              }

              return result;
            } catch (e) {
              debugPrint('Error in getAllAquariumsSummary: $e');
              return <AquariumSummary>[];
            }
          })
          .handleError((error) {
            debugPrint('Firebase error in getAllAquariumsSummary: $error');
            return <AquariumSummary>[];
          });
    }

    // Emit cached first, then live; also update when local cache changes
    final cacheWatch$ = LocalStorageService.instance
        .watchAllLatestSensorsLazy()
        .asyncMap(
          (_) => LocalStorageService.instance.getAllLatestSensorsLatest().then(
            (list) =>
                list
                    .map(
                      (e) => AquariumSummary(
                        aquariumId: (e['aquariumId'] ?? '').toString(),
                        name: '',
                        sensor: Sensor(
                          temperature: (e['temperature'] ?? 0).toDouble(),
                          turbidity: (e['turbidity'] ?? 0).toDouble(),
                          ph: (e['ph'] ?? 0).toDouble(),
                        ),
                      ),
                    )
                    .toList(),
          ),
        )
        .onErrorReturn(<AquariumSummary>[]);

    return Rx.merge<List<AquariumSummary>>([cached$, cacheWatch$, live$]);
  }

  Future<Threshold> fetchThresholds(String aquariumId) async {
    final db = _dbRef();
    if (db == null) {
      // Fallback defaults
      return Threshold(
        tempMin: 26,
        tempMax: 28,
        turbidityMin: 3,
        turbidityMax: 52,
        phMin: 6.5,
        phMax: 7.5,
      );
    }
    final snap = await db.child('aquariums/$aquariumId/threshold').get();
    final data = snap.value as Map?;
    return Threshold(
      tempMin: (data?['temperature']?['min'] ?? 0).toDouble(),
      tempMax: (data?['temperature']?['max'] ?? 0).toDouble(),
      turbidityMin: (data?['turbidity']?['min'] ?? 0).toDouble(),
      turbidityMax: (data?['turbidity']?['max'] ?? 0).toDouble(),
      phMin: (data?['ph']?['min'] ?? 0).toDouble(),
      phMax: (data?['ph']?['max'] ?? 0).toDouble(),
    );
  }

  Future<NotificationPref> fetchNotificationPrefs(String aquariumId) async {
    final db = _dbRef();
    if (db == null) {
      return NotificationPref(temperature: false, turbidity: false, ph: false);
    }
    final snap = await db.child('aquariums/$aquariumId/notification').get();
    final data = snap.value as Map?;
    return NotificationPref(
      temperature: data?['temperature'] ?? false,
      turbidity: data?['turbidity'] ?? false,
      ph: data?['ph'] ?? false,
    );
  }

  Future<void> setThresholds(String aquariumId, Threshold t) async {
    final db = _dbRef();
    if (db == null) return;
    await db.child('aquariums/$aquariumId/threshold').update({
      'temperature': {'min': t.tempMin, 'max': t.tempMax},
      'turbidity': {'min': t.turbidityMin, 'max': t.turbidityMax},
      'ph': {'min': t.phMin, 'max': t.phMax},
    });
  }

  Future<void> setNotificationPrefs(
    String aquariumId,
    NotificationPref n,
  ) async {
    final db = _dbRef();
    if (db == null) return;
    await db.child('aquariums/$aquariumId/notification').update({
      'temperature': n.temperature,
      'turbidity': n.turbidity,
      'ph': n.ph,
    });
  }

  // CRUD Operations for Aquariums
  Future<String> createAquarium(String name) async {
    try {
      final db = _dbRef();
      if (db == null) {
        throw Exception('Offline mode: cannot create aquarium');
      }
      // Get the next available ID
      final snapshot = await db.child('aquariums').get();
      final data = snapshot.value;
      String nextId = '1';

      if (data is Map) {
        final existingIds = data.keys.map((e) => int.tryParse(e) ?? 0).toList();
        if (existingIds.isNotEmpty) {
          nextId = (existingIds.reduce((a, b) => a > b ? a : b) + 1).toString();
        }
      } else if (data is List) {
        final existingIds =
            data
                .map(
                  (e) => int.tryParse(e['aquarium_id']?.toString() ?? '0') ?? 0,
                )
                .toList();
        if (existingIds.isNotEmpty) {
          nextId = (existingIds.reduce((a, b) => a > b ? a : b) + 1).toString();
        }
      }

      // Create new aquarium with default structure
      await db.child('aquariums/$nextId').set({
        'name': name,
        'sensors': {'temperature': 0, 'turbidity': 0, 'ph': 0},
        'threshold': {
          'temperature': {'min': 26, 'max': 28},
          'turbidity': {'min': 3, 'max': 52},
          'ph': {'min': 6.5, 'max': 7.5},
        },
        'notification': {'temperature': false, 'turbidity': false, 'ph': false},
        'hourly_log': {},
        'average': {},
      });

      return nextId;
    } catch (e) {
      debugPrint('Error creating aquarium: $e');
      rethrow;
    }
  }

  Future<void> updateAquariumName(String aquariumId, String newName) async {
    try {
      final db = _dbRef();
      if (db == null) throw Exception('Offline mode: cannot rename aquarium');
      await db.child('aquariums/$aquariumId/name').set(newName);
    } catch (e) {
      debugPrint('Error updating aquarium name: $e');
      rethrow;
    }
  }

  Future<void> deleteAquarium(String aquariumId) async {
    try {
      final db = _dbRef();
      if (db == null) throw Exception('Offline mode: cannot delete aquarium');
      await db.child('aquariums/$aquariumId').remove();
    } catch (e) {
      debugPrint('Error deleting aquarium: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationSettings(
    String aquariumId,
    bool temperature,
    bool turbidity,
    bool ph,
  ) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/notification').update({
        'temperature': temperature,
        'turbidity': turbidity,
        'ph': ph,
      });
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  Future<void> setAllAquariumNotifications({required bool enabled}) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      final snapshot = await db.child('aquariums').get();
      final data = snapshot.value;
      if (data is Map) {
        for (final entry in data.entries) {
          final id = entry.key.toString();
          await db.child('aquariums/$id/notification').update({
            'temperature': enabled,
            'turbidity': enabled,
            'ph': enabled,
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling all notifications: $e');
      rethrow;
    }
  }

  // Check if aquarium name already exists
  Future<bool> isAquariumNameExists(String name, {String? excludeId}) async {
    try {
      final db = _dbRef();
      if (db == null) return false;
      final snapshot = await db.child('aquariums').get();
      final data = snapshot.value;

      if (data is Map) {
        for (final entry in data.entries) {
          if (entry.key != excludeId && entry.value is Map) {
            final aquariumData = entry.value as Map;
            if (aquariumData['name'] == name) {
              return true;
            }
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map) {
            final id = item['aquarium_id']?.toString();
            if (id != excludeId && item['name'] == name) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking aquarium name: $e');
      return false;
    }
  }

  // Feeding functionality
  Future<void> updateAutoFeedStatus(String aquariumId, bool isActive) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/auto_feed').set(isActive);
    } catch (e) {
      debugPrint('Error updating auto-feed status: $e');
      rethrow;
    }
  }

  Future<void> triggerManualFeeding(String aquariumId) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/feeding').set({
        'manual': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
      });
    } catch (e) {
      debugPrint('Error triggering manual feeding: $e');
      rethrow;
    }
  }

  Future<void> stopManualFeeding(String aquariumId) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/feeding').update({
        'manual': false,
        'status': 'inactive',
      });
    } catch (e) {
      debugPrint('Error stopping manual feeding: $e');
      rethrow;
    }
  }

  Future<void> triggerRotationFeeding(String aquariumId, int rotations) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/feeding').set({
        'rotation': rotations,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('Error triggering rotation feeding: $e');
      rethrow;
    }
  }

  Stream<bool> getAutoFeedStatus(String aquariumId) {
    final db = _dbRef();
    if (db == null) return Stream<bool>.value(false);
    return db
        .child('aquariums/$aquariumId/auto_feed')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          return data == true;
        })
        .handleError((error) {
          debugPrint('Error getting auto-feed status: $error');
          return false;
        });
  }

  // Auto-light functionality
  Stream<bool> getAutoLightStatus(String aquariumId) {
    final db = _dbRef();
    if (db == null) return Stream<bool>.value(false);
    return db
        .child('aquariums/$aquariumId/auto_light')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          return data == true;
        })
        .handleError((error) {
          debugPrint('Error getting auto-light status: $error');
          return false;
        });
  }

  Future<void> setAutoLightStatus(String aquariumId, bool isActive) async {
    try {
      final db = _dbRef();
      if (db == null) return;
      await db.child('aquariums/$aquariumId/auto_light').set(isActive);
    } catch (e) {
      debugPrint('Error updating auto-light status: $e');
      rethrow;
    }
  }

  // Get current feeding status for safety monitoring
  Stream<Map<String, dynamic>> getFeedingStatus(String aquariumId) {
    final db = _dbRef();
    if (db == null) return Stream.value(<String, dynamic>{});
    return db
        .child('aquariums/$aquariumId/feeding')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data is Map) {
            return Map<String, dynamic>.from(data);
          }
          return <String, dynamic>{};
        })
        .handleError((error) {
          debugPrint('Error getting feeding status: $error');
          return <String, dynamic>{};
        });
  }
}
