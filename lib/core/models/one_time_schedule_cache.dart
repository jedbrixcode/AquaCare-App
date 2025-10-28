import 'package:isar/isar.dart';

part 'one_time_schedule_cache.g.dart';

@collection
class OneTimeScheduleCache {
  Id id = Isar.autoIncrement;
  late String aquariumId;
  late String documentId;
  late String scheduleTime; // yyyy-MM-dd HH:mm:ss
  late int cycle;
  late String food;
  late String status;
}
