import 'package:freezed_annotation/freezed_annotation.dart';

part 'aquarium_model.freezed.dart';
part 'aquarium_model.g.dart';

@freezed
class Aquarium with _$Aquarium {
  const factory Aquarium({required String id, required String name}) =
      _Aquarium;

  factory Aquarium.fromJson(Map<String, dynamic> json) =>
      _$AquariumFromJson(json);
}
