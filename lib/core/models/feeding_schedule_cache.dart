import 'package:isar/isar.dart';

part 'feeding_schedule_cache.g.dart';

@collection
class FeedingScheduleCache {
  Id id = Isar.autoIncrement;
  late String aquariumId;
  late String scheduleId; // use time string or backend id
  late String time; // HH:mm or server format
  late int cycles;
  late String foodType;
  late bool isEnabled;
  bool daily = false;
}
