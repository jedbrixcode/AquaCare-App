// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SensorImpl _$$SensorImplFromJson(Map<String, dynamic> json) => _$SensorImpl(
      temperature: (json['temperature'] as num).toDouble(),
      turbidity: (json['turbidity'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
    );

Map<String, dynamic> _$$SensorImplToJson(_$SensorImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'turbidity': instance.turbidity,
      'ph': instance.ph,
    };
