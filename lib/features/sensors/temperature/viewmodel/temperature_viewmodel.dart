import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';

class TemperatureRange {
  final double min;
  final double max;
  const TemperatureRange({required this.min, required this.max});
}

final temperatureRepositoryProvider = Provider<AquariumRepository>((ref) {
  return AquariumRepository();
});

final temperatureValueProvider = StreamProvider.family<double, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(temperatureRepositoryProvider);
  return repo.sensorStream(aquariumId).map((s) => s.temperature);
});

final temperatureThresholdProvider =
    FutureProvider.family<TemperatureRange, String>((ref, aquariumId) async {
      final repo = ref.watch(temperatureRepositoryProvider);
      final t = await repo.fetchThresholds(aquariumId);
      return TemperatureRange(min: t.tempMin, max: t.tempMax);
    });

final temperatureNotificationProvider = FutureProvider.family<bool, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(temperatureRepositoryProvider);
  final n = await repo.fetchNotificationPrefs(aquariumId);
  return n.temperature;
});

class TemperatureViewModel {
  final AquariumRepository repo;
  TemperatureViewModel(this.repo);

  Future<void> setTemperatureRange({
    required String aquariumId,
    required double min,
    required double max,
  }) async {
    final current = await repo.fetchThresholds(aquariumId);
    final updated = Threshold(
      tempMin: min,
      tempMax: max,
      turbidityMin: current.turbidityMin,
      turbidityMax: current.turbidityMax,
      phMin: current.phMin,
      phMax: current.phMax,
    );
    await repo.setThresholds(aquariumId, updated);
  }

  Future<void> setTemperatureNotification({
    required String aquariumId,
    required bool enabled,
  }) async {
    final current = await repo.fetchNotificationPrefs(aquariumId);
    await repo.setNotificationPrefs(
      aquariumId,
      current.copyWith(temperature: enabled),
    );
  }
}

final temperatureViewModelProvider = Provider<TemperatureViewModel>((ref) {
  final repo = ref.watch(temperatureRepositoryProvider);
  return TemperatureViewModel(repo);
});
