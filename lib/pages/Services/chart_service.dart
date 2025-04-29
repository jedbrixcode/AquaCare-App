import 'package:firebase_database/firebase_database.dart';

class SensorDataPoint {
  final double value;
  final String timestamp;
  final DateTime time;

  SensorDataPoint({
    required this.value,
    required this.timestamp,
    required this.time,
  });

  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:00';
  }
}

class ChartServices {
  static Future<List<SensorDataPoint>> fetchSensorData(
    String sensorType,
  ) async {
    final ref = FirebaseDatabase.instance.ref().child('Logs');
    final snapshot = await ref.get();

    List<SensorDataPoint> dataPoints = [];

    if (snapshot.exists) {
      for (final entry in snapshot.children) {
        if (entry.key == 'latest_id') continue;
        final data = entry.value as Map;
        final value = double.tryParse(data[sensorType]?.toString() ?? '');
        final timestamp = data['Timestamp']?.toString() ?? '';

        if (value != null && timestamp.isNotEmpty) {
          final time = DateTime.tryParse(timestamp) ?? DateTime.now();
          dataPoints.add(
            SensorDataPoint(value: value, timestamp: timestamp, time: time),
          );
        }
      }
    }

    return dataPoints;
  }
}
