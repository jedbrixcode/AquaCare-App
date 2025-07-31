// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sensor _$SensorFromJson(Map<String, dynamic> json) {
  return _Sensor.fromJson(json);
}

/// @nodoc
mixin _$Sensor {
  double get temperature => throw _privateConstructorUsedError;
  double get turbidity => throw _privateConstructorUsedError;
  double get ph => throw _privateConstructorUsedError;

  /// Serializes this Sensor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sensor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensorCopyWith<Sensor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorCopyWith<$Res> {
  factory $SensorCopyWith(Sensor value, $Res Function(Sensor) then) =
      _$SensorCopyWithImpl<$Res, Sensor>;
  @useResult
  $Res call({double temperature, double turbidity, double ph});
}

/// @nodoc
class _$SensorCopyWithImpl<$Res, $Val extends Sensor>
    implements $SensorCopyWith<$Res> {
  _$SensorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sensor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? turbidity = null,
    Object? ph = null,
  }) {
    return _then(_value.copyWith(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      turbidity: null == turbidity
          ? _value.turbidity
          : turbidity // ignore: cast_nullable_to_non_nullable
              as double,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SensorImplCopyWith<$Res> implements $SensorCopyWith<$Res> {
  factory _$$SensorImplCopyWith(
          _$SensorImpl value, $Res Function(_$SensorImpl) then) =
      __$$SensorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double temperature, double turbidity, double ph});
}

/// @nodoc
class __$$SensorImplCopyWithImpl<$Res>
    extends _$SensorCopyWithImpl<$Res, _$SensorImpl>
    implements _$$SensorImplCopyWith<$Res> {
  __$$SensorImplCopyWithImpl(
      _$SensorImpl _value, $Res Function(_$SensorImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sensor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? turbidity = null,
    Object? ph = null,
  }) {
    return _then(_$SensorImpl(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      turbidity: null == turbidity
          ? _value.turbidity
          : turbidity // ignore: cast_nullable_to_non_nullable
              as double,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SensorImpl implements _Sensor {
  const _$SensorImpl(
      {required this.temperature, required this.turbidity, required this.ph});

  factory _$SensorImpl.fromJson(Map<String, dynamic> json) =>
      _$$SensorImplFromJson(json);

  @override
  final double temperature;
  @override
  final double turbidity;
  @override
  final double ph;

  @override
  String toString() {
    return 'Sensor(temperature: $temperature, turbidity: $turbidity, ph: $ph)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.turbidity, turbidity) ||
                other.turbidity == turbidity) &&
            (identical(other.ph, ph) || other.ph == ph));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, temperature, turbidity, ph);

  /// Create a copy of Sensor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorImplCopyWith<_$SensorImpl> get copyWith =>
      __$$SensorImplCopyWithImpl<_$SensorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SensorImplToJson(
      this,
    );
  }
}

abstract class _Sensor implements Sensor {
  const factory _Sensor(
      {required final double temperature,
      required final double turbidity,
      required final double ph}) = _$SensorImpl;

  factory _Sensor.fromJson(Map<String, dynamic> json) = _$SensorImpl.fromJson;

  @override
  double get temperature;
  @override
  double get turbidity;
  @override
  double get ph;

  /// Create a copy of Sensor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorImplCopyWith<_$SensorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
