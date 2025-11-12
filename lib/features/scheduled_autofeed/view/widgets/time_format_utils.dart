import 'package:flutter/material.dart';

TimeOfDay? parseTimeOfDay(String input) {
  final parts = input.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return TimeOfDay(hour: h, minute: m);
}

String formatTimeOfDay(TimeOfDay t) {
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String formatDisplay(TimeOfDay t) {
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final minute = t.minute.toString().padLeft(2, '0');
  final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

TimeOfDay? parseTimeOfDayDisplay(String input) {
  final trimmed = input.trim().toUpperCase();
  final am = trimmed.endsWith('AM');
  final pm = trimmed.endsWith('PM');
  if (!am && !pm) return null;
  final timePart = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
  final parts = timePart.split(':');
  if (parts.length != 2) return null;
  final hour12 = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour12 == null || minute == null) return null;
  if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59) return null;
  int hour24 = hour12 % 12;
  if (pm) hour24 += 12;
  return TimeOfDay(hour: hour24, minute: minute);
}

String format24FromDisplay(String display) {
  final t = parseTimeOfDayDisplay(display);
  if (t == null) return '08:00';
  return formatTimeOfDay(t);
}

String formatDisplayFrom24(String hhmm) {
  final t = parseTimeOfDay(hhmm) ?? const TimeOfDay(hour: 8, minute: 0);
  return formatDisplay(t);
}

String formatScheduleDateOnly(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString);
    final mm = dateTime.month.toString().padLeft(2, '0');
    final dd = dateTime.day.toString().padLeft(2, '0');
    final yyyy = dateTime.year.toString();
    int hour = dateTime.hour;
    final minute2 = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return '$mm-$dd-$yyyy at $hour:$minute2 $period';
  } catch (_) {
    return dateTimeString;
  }
}
