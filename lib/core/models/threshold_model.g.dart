// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threshold_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThresholdImpl _$$ThresholdImplFromJson(Map<String, dynamic> json) =>
    _$ThresholdImpl(
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      turbidityMin: (json['turbidityMin'] as num).toDouble(),
      turbidityMax: (json['turbidityMax'] as num).toDouble(),
      phMin: (json['phMin'] as num).toDouble(),
      phMax: (json['phMax'] as num).toDouble(),
    );

Map<String, dynamic> _$$ThresholdImplToJson(_$ThresholdImpl instance) =>
    <String, dynamic>{
      'tempMin': instance.tempMin,
      'tempMax': instance.tempMax,
      'turbidityMin': instance.turbidityMin,
      'turbidityMax': instance.turbidityMax,
      'phMin': instance.phMin,
      'phMax': instance.phMax,
    };
