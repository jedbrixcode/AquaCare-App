import 'package:isar/isar.dart';

part 'average_log.g.dart';

@Collection()
class AverageLog {
  Id id = Isar.autoIncrement;
  late String aquariumId;
  late int dayIndex;
  late double temperature;
  late double ph;
  late double turbidity;
}
