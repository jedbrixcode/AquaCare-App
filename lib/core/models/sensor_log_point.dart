class SensorLogPoint {
  final double value;
  final DateTime time;
  final String label;

  const SensorLogPoint({
    required this.value,
    required this.time,
    required this.label,
  });

  String get formattedTime => '${time.hour.toString().padLeft(2, '0')}:00';
}
