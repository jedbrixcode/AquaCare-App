import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';

class AquariumRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String aquariumId = '1'; // For now, hardcoded to Aquarium 1

  Stream<Sensor> sensorStream() {
    return _db.child('aquariums/$aquariumId/sensors').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return Sensor(
        temperature: (data?['temperature'] ?? 0).toDouble(),
        turbidity: (data?['turbidity'] ?? 0).toDouble(),
        ph: (data?['ph'] ?? 0).toDouble(),
      );
    });
  }

  Future<Threshold> fetchThresholds() async {
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

  Future<NotificationPref> fetchNotificationPrefs() async {
    final snap = await _db.child('aquariums/$aquariumId/notification').get();
    final data = snap.value as Map?;
    return NotificationPref(
      temperature: data?['temperature'] ?? false,
      turbidity: data?['turbidity'] ?? false,
      ph: data?['ph'] ?? false,
    );
  }

  Future<void> setThresholds(Threshold t) async {
    await _db.child('aquariums/$aquariumId/threshold').update({
      'temperature': {'min': t.tempMin, 'max': t.tempMax},
      'turbidity': {'min': t.turbidityMin, 'max': t.turbidityMax},
      'ph': {'min': t.phMin, 'max': t.phMax},
    });
  }

  Future<void> setNotificationPrefs(NotificationPref n) async {
    await _db.child('aquariums/$aquariumId/notification').update({
      'temperature': n.temperature,
      'turbidity': n.turbidity,
      'ph': n.ph,
    });
  }
}
