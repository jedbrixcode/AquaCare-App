import 'package:isar/isar.dart';

part 'latest_sensor.g.dart';

@Collection()
class LatestSensor {
  Id id = Isar.autoIncrement;
  late String aquariumId;
  late double temperature;
  late double ph;
  late double turbidity;
  late int timestampMs;
}
