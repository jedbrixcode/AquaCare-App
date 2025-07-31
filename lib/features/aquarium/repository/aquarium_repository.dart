import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';

class AquariumRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Get all aquarium IDs from the database
  Stream<List<String>> getAllAquariumIds() {
    return _db.child('aquariums').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <String>[];

      return data.keys.cast<String>().toList();
    });
  }

  // Get sensor data for a specific aquarium
  Stream<Sensor> sensorStream(String aquariumId) {
    return _db.child('aquariums/$aquariumId/sensors').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return Sensor(
        temperature: (data?['temperature'] ?? 0).toDouble(),
        turbidity: (data?['turbidity'] ?? 0).toDouble(),
        ph: (data?['ph'] ?? 0).toDouble(),
      );
    });
  }

  // Get all aquariums with their sensor data
  Stream<Map<String, Sensor>> getAllAquariumsData() {
    return _db.child('aquariums').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <String, Sensor>{};

      final Map<String, Sensor> aquariums = {};

      for (String aquariumId in data.keys) {
        final aquariumData = data[aquariumId] as Map?;
        final sensorsData = aquariumData?['sensors'] as Map?;

        if (sensorsData != null) {
          aquariums[aquariumId] = Sensor(
            temperature: (sensorsData['temperature'] ?? 0).toDouble(),
            turbidity: (sensorsData['turbidity'] ?? 0).toDouble(),
            ph: (sensorsData['ph'] ?? 0).toDouble(),
          );
        }
      }

      return aquariums;
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
}
