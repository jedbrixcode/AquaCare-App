// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationPref _$NotificationPrefFromJson(Map<String, dynamic> json) {
  return _NotificationPref.fromJson(json);
}

/// @nodoc
mixin _$NotificationPref {
  bool get temperature => throw _privateConstructorUsedError;
  bool get turbidity => throw _privateConstructorUsedError;
  bool get ph => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationPrefCopyWith<NotificationPref> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPrefCopyWith<$Res> {
  factory $NotificationPrefCopyWith(
          NotificationPref value, $Res Function(NotificationPref) then) =
      _$NotificationPrefCopyWithImpl<$Res, NotificationPref>;
  @useResult
  $Res call({bool temperature, bool turbidity, bool ph});
}

/// @nodoc
class _$NotificationPrefCopyWithImpl<$Res, $Val extends NotificationPref>
    implements $NotificationPrefCopyWith<$Res> {
  _$NotificationPrefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
              as bool,
      turbidity: null == turbidity
          ? _value.turbidity
          : turbidity // ignore: cast_nullable_to_non_nullable
              as bool,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPrefImplCopyWith<$Res>
    implements $NotificationPrefCopyWith<$Res> {
  factory _$$NotificationPrefImplCopyWith(_$NotificationPrefImpl value,
          $Res Function(_$NotificationPrefImpl) then) =
      __$$NotificationPrefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool temperature, bool turbidity, bool ph});
}

/// @nodoc
class __$$NotificationPrefImplCopyWithImpl<$Res>
    extends _$NotificationPrefCopyWithImpl<$Res, _$NotificationPrefImpl>
    implements _$$NotificationPrefImplCopyWith<$Res> {
  __$$NotificationPrefImplCopyWithImpl(_$NotificationPrefImpl _value,
      $Res Function(_$NotificationPrefImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? turbidity = null,
    Object? ph = null,
  }) {
    return _then(_$NotificationPrefImpl(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as bool,
      turbidity: null == turbidity
          ? _value.turbidity
          : turbidity // ignore: cast_nullable_to_non_nullable
              as bool,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPrefImpl implements _NotificationPref {
  const _$NotificationPrefImpl(
      {required this.temperature, required this.turbidity, required this.ph});

  factory _$NotificationPrefImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPrefImplFromJson(json);

  @override
  final bool temperature;
  @override
  final bool turbidity;
  @override
  final bool ph;

  @override
  String toString() {
    return 'NotificationPref(temperature: $temperature, turbidity: $turbidity, ph: $ph)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPrefImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.turbidity, turbidity) ||
                other.turbidity == turbidity) &&
            (identical(other.ph, ph) || other.ph == ph));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, temperature, turbidity, ph);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPrefImplCopyWith<_$NotificationPrefImpl> get copyWith =>
      __$$NotificationPrefImplCopyWithImpl<_$NotificationPrefImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPrefImplToJson(
      this,
    );
  }
}

abstract class _NotificationPref implements NotificationPref {
  const factory _NotificationPref(
      {required final bool temperature,
      required final bool turbidity,
      required final bool ph}) = _$NotificationPrefImpl;

  factory _NotificationPref.fromJson(Map<String, dynamic> json) =
      _$NotificationPrefImpl.fromJson;

  @override
  bool get temperature;
  @override
  bool get turbidity;
  @override
  bool get ph;
  @override
  @JsonKey(ignore: true)
  _$$NotificationPrefImplCopyWith<_$NotificationPrefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
