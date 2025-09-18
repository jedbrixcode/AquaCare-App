import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/core/models/sensor_log_point.dart';

class GraphsRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<SensorLogPoint>> fetchDaily(String sensorType) async {
    final snapshot = await _db.child('Logs').get();
    final List<SensorLogPoint> points = [];
    if (snapshot.exists) {
      for (final entry in snapshot.children) {
        if (entry.key == 'latest_id') continue;
        final data = entry.value as Map;
        final value = double.tryParse(data[sensorType]?.toString() ?? '');
        final ts = data['Timestamp']?.toString() ?? '';
        if (value != null && ts.isNotEmpty) {
          final time = DateTime.tryParse(ts) ?? DateTime.now();
          points.add(
            SensorLogPoint(value: value, time: time, label: sensorType),
          );
        }
      }
    }
    return points;
  }

  Future<List<SensorLogPoint>> fetchWeeklyAverages() async {
    final snapshot = await _db.child('Average').get();
    if (!snapshot.exists) return [];
    final List<SensorLogPoint> points = [];
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    for (final e in map.entries) {
      final sensorName = e.key;
      final values = List<dynamic>.from(e.value);
      for (int i = 0; i < values.length; i++) {
        final val = values[i];
        if (val == null) continue;
        points.add(
          SensorLogPoint(
            value: (val as num).toDouble(),
            time: DateTime.now().subtract(Duration(days: values.length - i)),
            label: sensorName,
          ),
        );
      }
    }
    return points;
  }
}

final graphsRepositoryProvider = Provider<GraphsRepository>((ref) {
  return GraphsRepository();
});
