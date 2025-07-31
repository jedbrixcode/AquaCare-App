// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPrefImpl _$$NotificationPrefImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPrefImpl(
      temperature: json['temperature'] as bool,
      turbidity: json['turbidity'] as bool,
      ph: json['ph'] as bool,
    );

Map<String, dynamic> _$$NotificationPrefImplToJson(
        _$NotificationPrefImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'turbidity': instance.turbidity,
      'ph': instance.ph,
    };
