import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationPref with _$NotificationPref {
  const factory NotificationPref({
    required bool temperature,
    required bool turbidity,
    required bool ph,
  }) = _NotificationPref;

  factory NotificationPref.fromJson(Map<String, dynamic> json) =>
      _$NotificationPrefFromJson(json);
}
