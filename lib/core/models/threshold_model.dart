import 'package:freezed_annotation/freezed_annotation.dart';

part 'threshold_model.freezed.dart';
part 'threshold_model.g.dart';

@freezed
class Threshold with _$Threshold {
  const factory Threshold({
    required double tempMin,
    required double tempMax,
    required double turbidityMin,
    required double turbidityMax,
    required double phMin,
    required double phMax,
  }) = _Threshold;

  factory Threshold.fromJson(Map<String, dynamic> json) =>
      _$ThresholdFromJson(json);
}
