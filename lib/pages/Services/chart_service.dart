import 'package:firebase_database/firebase_database.dart';

class SensorDataPoint {
  final double value;
  final String timestamp;
  final DateTime time;
  final String label;

  SensorDataPoint({
    required this.value,
    required this.timestamp,
    required this.time,
    required this.label,
  });

  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:00';
  }
}

class ChartServices {
  // Fetch daily log data from 'Logs' node
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
            SensorDataPoint(
              value: value,
              timestamp: timestamp,
              time: time,
              label: sensorType,
            ),
          );
        }
      }
    }

    return dataPoints;
  }

  // Fetch weekly average data from 'Average' node
  static Future<List<SensorDataPoint>> fetchAverageData() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Average').get();

    if (!snapshot.exists) return [];

    final List<SensorDataPoint> dataPoints = [];

    final Map<String, dynamic> averages = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    for (final entry in averages.entries) {
      final sensorName = entry.key;
      final values = List<dynamic>.from(entry.value);

      for (int i = 0; i < values.length; i++) {
        final val = values[i];
        if (val == null) continue;
        dataPoints.add(
          SensorDataPoint(
            value: val.toDouble(),
            timestamp: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1],
            time: DateTime.now().subtract(Duration(days: values.length - i)),
            label: sensorName,
          ),
        );
      }
    }

    return dataPoints;
  }
}
