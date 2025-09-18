import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';

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
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Get all aquarium IDs from the database (supports both Map and List structures)
  Stream<List<String>> getAllAquariumIds() {
    return _db.child('aquariums').onValue.map((event) {
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
    return _db
        .child('aquariums/$aquariumId/sensors')
        .onValue
        .map((event) {
          try {
            final data = event.snapshot.value as Map?;
            if (data == null) {
              return Sensor(temperature: 0, turbidity: 0, ph: 0);
            }
            return Sensor(
              temperature: (data['temperature'] ?? 0).toDouble(),
              turbidity: (data['turbidity'] ?? 0).toDouble(),
              ph: (data['ph'] ?? 0).toDouble(),
            );
          } catch (e) {
            print('Error processing sensor data for aquarium $aquariumId: $e');
            return Sensor(temperature: 0, turbidity: 0, ph: 0);
          }
        })
        .handleError((error) {
          print(
            'Firebase error in sensorStream for aquarium $aquariumId: $error',
          );
          return Sensor(temperature: 0, turbidity: 0, ph: 0);
        });
  }

  // Stream of all aquariums with name and sensors (supports Map and List)
  Stream<List<AquariumSummary>> getAllAquariumsSummary() {
    return _db
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
                  // Skip invalid aquarium data
                  print('Error processing aquarium $key: $e');
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
                  // Skip invalid aquarium data
                  print('Error processing aquarium item: $e');
                }
              }
              return result;
            }

            return result;
          } catch (e) {
            print('Error in getAllAquariumsSummary: $e');
            return <AquariumSummary>[];
          }
        })
        .handleError((error) {
          print('Firebase error in getAllAquariumsSummary: $error');
          return <AquariumSummary>[];
        });
  }

  Future<Threshold> fetchThresholds(String aquariumId) async {
    final snap = await _db.child('aquariums/$aquariumId/threshold').get();
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
    final snap = await _db.child('aquariums/$aquariumId/notification').get();
    final data = snap.value as Map?;
    return NotificationPref(
      temperature: data?['temperature'] ?? false,
      turbidity: data?['turbidity'] ?? false,
      ph: data?['ph'] ?? false,
    );
  }

  Future<void> setThresholds(String aquariumId, Threshold t) async {
    await _db.child('aquariums/$aquariumId/threshold').update({
      'temperature': {'min': t.tempMin, 'max': t.tempMax},
      'turbidity': {'min': t.turbidityMin, 'max': t.turbidityMax},
      'ph': {'min': t.phMin, 'max': t.phMax},
    });
  }

  Future<void> setNotificationPrefs(
    String aquariumId,
    NotificationPref n,
  ) async {
    await _db.child('aquariums/$aquariumId/notification').update({
      'temperature': n.temperature,
      'turbidity': n.turbidity,
      'ph': n.ph,
    });
  }

  // CRUD Operations for Aquariums
  Future<String> createAquarium(String name) async {
    try {
      // Get the next available ID
      final snapshot = await _db.child('aquariums').get();
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
      await _db.child('aquariums/$nextId').set({
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
      print('Error creating aquarium: $e');
      rethrow;
    }
  }

  Future<void> updateAquariumName(String aquariumId, String newName) async {
    try {
      await _db.child('aquariums/$aquariumId/name').set(newName);
    } catch (e) {
      print('Error updating aquarium name: $e');
      rethrow;
    }
  }

  Future<void> deleteAquarium(String aquariumId) async {
    try {
      await _db.child('aquariums/$aquariumId').remove();
    } catch (e) {
      print('Error deleting aquarium: $e');
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
      await _db.child('aquariums/$aquariumId/notification').update({
        'temperature': temperature,
        'turbidity': turbidity,
        'ph': ph,
      });
    } catch (e) {
      print('Error updating notification settings: $e');
      rethrow;
    }
  }

  Future<void> setAllAquariumNotifications({required bool enabled}) async {
    try {
      final snapshot = await _db.child('aquariums').get();
      final data = snapshot.value;
      if (data is Map) {
        for (final entry in data.entries) {
          final id = entry.key.toString();
          await _db.child('aquariums/$id/notification').update({
            'temperature': enabled,
            'turbidity': enabled,
            'ph': enabled,
          });
        }
      }
    } catch (e) {
      print('Error toggling all notifications: $e');
      rethrow;
    }
  }

  // Check if aquarium name already exists
  Future<bool> isAquariumNameExists(String name, {String? excludeId}) async {
    try {
      final snapshot = await _db.child('aquariums').get();
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
      print('Error checking aquarium name: $e');
      return false;
    }
  }

  // Feeding functionality
  Future<void> updateAutoFeedStatus(String aquariumId, bool isActive) async {
    try {
      await _db.child('aquariums/$aquariumId/auto_feed').set(isActive);
    } catch (e) {
      print('Error updating auto-feed status: $e');
      rethrow;
    }
  }

  Future<void> triggerManualFeeding(String aquariumId) async {
    try {
      await _db.child('aquariums/$aquariumId/feeding').set({
        'manual': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
      });
    } catch (e) {
      print('Error triggering manual feeding: $e');
      rethrow;
    }
  }

  Future<void> stopManualFeeding(String aquariumId) async {
    try {
      await _db.child('aquariums/$aquariumId/feeding').update({
        'manual': false,
        'status': 'inactive',
      });
    } catch (e) {
      print('Error stopping manual feeding: $e');
      rethrow;
    }
  }

  Future<void> triggerRotationFeeding(String aquariumId, int rotations) async {
    try {
      await _db.child('aquariums/$aquariumId/feeding').set({
        'rotation': rotations,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
      });
    } catch (e) {
      print('Error triggering rotation feeding: $e');
      rethrow;
    }
  }

  Stream<bool> getAutoFeedStatus(String aquariumId) {
    return _db
        .child('aquariums/$aquariumId/auto_feed')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          return data == true;
        })
        .handleError((error) {
          print('Error getting auto-feed status: $error');
          return false;
        });
  }

  // Auto-light functionality
  Stream<bool> getAutoLightStatus(String aquariumId) {
    return _db
        .child('aquariums/$aquariumId/auto_light')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          return data == true;
        })
        .handleError((error) {
          print('Error getting auto-light status: $error');
          return false;
        });
  }

  Future<void> setAutoLightStatus(String aquariumId, bool isActive) async {
    try {
      await _db.child('aquariums/$aquariumId/auto_light').set(isActive);
    } catch (e) {
      print('Error updating auto-light status: $e');
      rethrow;
    }
  }

  // Get current feeding status for safety monitoring
  Stream<Map<String, dynamic>> getFeedingStatus(String aquariumId) {
    return _db
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
          print('Error getting feeding status: $error');
          return <String, dynamic>{};
        });
  }
}
