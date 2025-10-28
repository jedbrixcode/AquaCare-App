import 'package:meta/meta.dart';

@immutable
class OneTimeSchedule {
  final String id;
  final int aquariumId;
  final String scheduleTime; // "YYYY-MM-DD HH:mm:ss" local time
  final int cycle;
  final String food;
  final String status; // pending | running | done | cancelled

  const OneTimeSchedule({
    required this.id,
    required this.aquariumId,
    required this.scheduleTime,
    required this.cycle,
    required this.food,
    required this.status,
  });

  factory OneTimeSchedule.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    final aqRaw = json['aquarium_id'];
    final cycleRaw = json['cycle'];
    final stRaw = json['schedule_time'];

    int parsedAquariumId;
    if (aqRaw is num) {
      parsedAquariumId = aqRaw.toInt();
    } else if (aqRaw is String) {
      parsedAquariumId = int.tryParse(aqRaw) ?? 0;
    } else {
      parsedAquariumId = 0;
    }

    int parsedCycle = 0;
    if (cycleRaw is num) {
      parsedCycle = cycleRaw.toInt();
    } else if (cycleRaw is String) {
      parsedCycle = int.tryParse(cycleRaw) ?? 0;
    }

    String scheduleStr;
    if (stRaw is String) {
      scheduleStr = stRaw;
    } else if (stRaw is TimestampLike) {
      // Allow injection via extension below when using Firestore Timestamp
      scheduleStr = stRaw.toLocalDateTimeString();
    } else {
      scheduleStr = '';
    }

    return OneTimeSchedule(
      id: id,
      aquariumId: parsedAquariumId,
      scheduleTime: scheduleStr,
      cycle: parsedCycle,
      food: (json['food'] as String? ?? ''),
      status: (json['status'] as String? ?? 'pending'),
    );
  }

  DateTime? get scheduledAtLocal {
    try {
      // The backend uses local time string like "2025-11-03 14:30:00"
      return DateTime.parse(scheduleTime);
    } catch (_) {
      return null;
    }
  }
}

// Lightweight adapter to avoid importing Firestore Timestamp directly here
abstract class TimestampLike {
  String toLocalDateTimeString();
}
