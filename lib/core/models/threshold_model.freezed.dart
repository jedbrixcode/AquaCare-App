// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'threshold_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Threshold _$ThresholdFromJson(Map<String, dynamic> json) {
  return _Threshold.fromJson(json);
}

/// @nodoc
mixin _$Threshold {
  double get tempMin => throw _privateConstructorUsedError;
  double get tempMax => throw _privateConstructorUsedError;
  double get turbidityMin => throw _privateConstructorUsedError;
  double get turbidityMax => throw _privateConstructorUsedError;
  double get phMin => throw _privateConstructorUsedError;
  double get phMax => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ThresholdCopyWith<Threshold> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThresholdCopyWith<$Res> {
  factory $ThresholdCopyWith(Threshold value, $Res Function(Threshold) then) =
      _$ThresholdCopyWithImpl<$Res, Threshold>;
  @useResult
  $Res call(
      {double tempMin,
      double tempMax,
      double turbidityMin,
      double turbidityMax,
      double phMin,
      double phMax});
}

/// @nodoc
class _$ThresholdCopyWithImpl<$Res, $Val extends Threshold>
    implements $ThresholdCopyWith<$Res> {
  _$ThresholdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tempMin = null,
    Object? tempMax = null,
    Object? turbidityMin = null,
    Object? turbidityMax = null,
    Object? phMin = null,
    Object? phMax = null,
  }) {
    return _then(_value.copyWith(
      tempMin: null == tempMin
          ? _value.tempMin
          : tempMin // ignore: cast_nullable_to_non_nullable
              as double,
      tempMax: null == tempMax
          ? _value.tempMax
          : tempMax // ignore: cast_nullable_to_non_nullable
              as double,
      turbidityMin: null == turbidityMin
          ? _value.turbidityMin
          : turbidityMin // ignore: cast_nullable_to_non_nullable
              as double,
      turbidityMax: null == turbidityMax
          ? _value.turbidityMax
          : turbidityMax // ignore: cast_nullable_to_non_nullable
              as double,
      phMin: null == phMin
          ? _value.phMin
          : phMin // ignore: cast_nullable_to_non_nullable
              as double,
      phMax: null == phMax
          ? _value.phMax
          : phMax // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThresholdImplCopyWith<$Res>
    implements $ThresholdCopyWith<$Res> {
  factory _$$ThresholdImplCopyWith(
          _$ThresholdImpl value, $Res Function(_$ThresholdImpl) then) =
      __$$ThresholdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double tempMin,
      double tempMax,
      double turbidityMin,
      double turbidityMax,
      double phMin,
      double phMax});
}

/// @nodoc
class __$$ThresholdImplCopyWithImpl<$Res>
    extends _$ThresholdCopyWithImpl<$Res, _$ThresholdImpl>
    implements _$$ThresholdImplCopyWith<$Res> {
  __$$ThresholdImplCopyWithImpl(
      _$ThresholdImpl _value, $Res Function(_$ThresholdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tempMin = null,
    Object? tempMax = null,
    Object? turbidityMin = null,
    Object? turbidityMax = null,
    Object? phMin = null,
    Object? phMax = null,
  }) {
    return _then(_$ThresholdImpl(
      tempMin: null == tempMin
          ? _value.tempMin
          : tempMin // ignore: cast_nullable_to_non_nullable
              as double,
      tempMax: null == tempMax
          ? _value.tempMax
          : tempMax // ignore: cast_nullable_to_non_nullable
              as double,
      turbidityMin: null == turbidityMin
          ? _value.turbidityMin
          : turbidityMin // ignore: cast_nullable_to_non_nullable
              as double,
      turbidityMax: null == turbidityMax
          ? _value.turbidityMax
          : turbidityMax // ignore: cast_nullable_to_non_nullable
              as double,
      phMin: null == phMin
          ? _value.phMin
          : phMin // ignore: cast_nullable_to_non_nullable
              as double,
      phMax: null == phMax
          ? _value.phMax
          : phMax // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThresholdImpl implements _Threshold {
  const _$ThresholdImpl(
      {required this.tempMin,
      required this.tempMax,
      required this.turbidityMin,
      required this.turbidityMax,
      required this.phMin,
      required this.phMax});

  factory _$ThresholdImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThresholdImplFromJson(json);

  @override
  final double tempMin;
  @override
  final double tempMax;
  @override
  final double turbidityMin;
  @override
  final double turbidityMax;
  @override
  final double phMin;
  @override
  final double phMax;

  @override
  String toString() {
    return 'Threshold(tempMin: $tempMin, tempMax: $tempMax, turbidityMin: $turbidityMin, turbidityMax: $turbidityMax, phMin: $phMin, phMax: $phMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThresholdImpl &&
            (identical(other.tempMin, tempMin) || other.tempMin == tempMin) &&
            (identical(other.tempMax, tempMax) || other.tempMax == tempMax) &&
            (identical(other.turbidityMin, turbidityMin) ||
                other.turbidityMin == turbidityMin) &&
            (identical(other.turbidityMax, turbidityMax) ||
                other.turbidityMax == turbidityMax) &&
            (identical(other.phMin, phMin) || other.phMin == phMin) &&
            (identical(other.phMax, phMax) || other.phMax == phMax));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, tempMin, tempMax, turbidityMin, turbidityMax, phMin, phMax);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ThresholdImplCopyWith<_$ThresholdImpl> get copyWith =>
      __$$ThresholdImplCopyWithImpl<_$ThresholdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThresholdImplToJson(
      this,
    );
  }
}

abstract class _Threshold implements Threshold {
  const factory _Threshold(
      {required final double tempMin,
      required final double tempMax,
      required final double turbidityMin,
      required final double turbidityMax,
      required final double phMin,
      required final double phMax}) = _$ThresholdImpl;

  factory _Threshold.fromJson(Map<String, dynamic> json) =
      _$ThresholdImpl.fromJson;

  @override
  double get tempMin;
  @override
  double get tempMax;
  @override
  double get turbidityMin;
  @override
  double get turbidityMax;
  @override
  double get phMin;
  @override
  double get phMax;
  @override
  @JsonKey(ignore: true)
  _$$ThresholdImplCopyWith<_$ThresholdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
