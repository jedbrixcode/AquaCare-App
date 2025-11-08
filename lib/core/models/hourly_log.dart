import 'package:isar/isar.dart';

part 'hourly_log.g.dart';

@Collection()
class HourlyLog {
  Id id = Isar.autoIncrement;
  late String aquariumId;
  late int hourIndex;
  late double temperature;
  late double ph;
  late double turbidity;
}
