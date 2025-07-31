import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_model.freezed.dart';
part 'sensor_model.g.dart';

@freezed
class Sensor with _$Sensor {
  const factory Sensor({
    required double temperature,
    required double turbidity,
    required double ph,
  }) = _Sensor;

  factory Sensor.fromJson(Map<String, dynamic> json) => _$SensorFromJson(json);
}
