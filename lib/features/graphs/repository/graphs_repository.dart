import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/core/models/sensor_log_point.dart';

class GraphsRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<String>> fetchAquariumNames() async {
    final snapshot = await _db.child('aquariums').get();
    final List<String> names = [];

    if (snapshot.exists) {
      for (final aquarium in snapshot.children) {
        final data = aquarium.value as Map?;
        final name = data?['name']?.toString();
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }
    }

    return names;
  }

  Future<Map<String, String>> fetchAquariumIdNameMap() async {
    final snapshot = await _db.child('aquariums').get();
    final Map<String, String> map = {};

    if (snapshot.exists) {
      for (final aquarium in snapshot.children) {
        final data = aquarium.value as Map?;
        final id = aquarium.key; // Firebase node key
        final name = data?['name']?.toString();
        if (id != null && name != null && name.isNotEmpty) {
          map[name] = id;
        }
      }
    }

    return map;
  }

  Stream<List<String>> fetchAquariumNamesStream() {
    return _db.child('aquariums').onValue.map((event) {
      final List<String> names = [];
      if (!event.snapshot.exists) return names;

      for (final aquarium in event.snapshot.children) {
        final data = aquarium.value as Map?;
        final name = data?['name']?.toString();
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }
      return names;
    });
  }

  /// Fetch hourly (daily) sensor readings for a specific aquarium
  Future<List<SensorLogPoint>> fetchDaily(
    String sensorType,
    String aquariumId,
  ) async {
    final snapshot = await _db.child('aquariums/$aquariumId/hourly_log').get();
    final List<SensorLogPoint> points = [];

    if (snapshot.exists) {
      for (final entry in snapshot.children) {
        final key = int.tryParse(entry.key ?? '');
        if (key == null) continue;
        // Skip non-map entries like "index"
        final raw = entry.value;
        if (raw is! Map) continue;
        final data = Map<String, dynamic>.from(raw);
        final value = double.tryParse(
          data[sensorType.toLowerCase()]?.toString() ?? '',
        );
        if (value == null) continue;

        // Use the hour index directly as X-axis
        points.add(
          SensorLogPoint(
            value: value,
            time: DateTime(0).add(Duration(hours: key)), // x-axis = 0..23
            label: sensorType,
          ),
        );
      }
    }

    // Sort by hour just in case
    points.sort((a, b) => a.time.hour.compareTo(b.time.hour));

    return points;
  }

  /// Fetch weekly averages for a specific aquarium
  Future<List<SensorLogPoint>> fetchWeeklyAverages(String aquariumId) async {
    final snapshot = await _db.child('aquariums/$aquariumId/average').get();
    if (!snapshot.exists) return [];

    final List<SensorLogPoint> points = [];
    final value = snapshot.value;
    if (value is! Map) return [];
    final map = Map<String, dynamic>.from(value);

    // Backend structure:
    // average: {
    //   "1": { ph: 7.1, temperature: 25.5, turbidity: 3.2 },
    //   "2": { ... },
    //   "index": 2
    // }
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
    }

    return points;
  }
}

final graphsRepositoryProvider = Provider<GraphsRepository>((ref) {
  return GraphsRepository();
});
