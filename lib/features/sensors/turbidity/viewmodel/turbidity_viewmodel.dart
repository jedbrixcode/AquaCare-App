import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';

class TurbidityRange {
  final double min;
  final double max;
  const TurbidityRange({required this.min, required this.max});
}

final turbidityRepositoryProvider = Provider<AquariumRepository>((ref) {
  return AquariumRepository();
});

final turbidityValueProvider = StreamProvider.family<double, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(turbidityRepositoryProvider);
  return repo.sensorStream(aquariumId).map((s) => s.turbidity);
});

final turbidityThresholdProvider =
    FutureProvider.family<TurbidityRange, String>((ref, aquariumId) async {
      final repo = ref.watch(turbidityRepositoryProvider);
      final t = await repo.fetchThresholds(aquariumId);
      return TurbidityRange(min: t.turbidityMin, max: t.turbidityMax);
    });

final turbidityNotificationProvider = FutureProvider.family<bool, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(turbidityRepositoryProvider);
  final n = await repo.fetchNotificationPrefs(aquariumId);
  return n.turbidity;
});

class TurbidityViewModel {
  final AquariumRepository repo;
  TurbidityViewModel(this.repo);

  Future<void> setTurbidityRange({
    required String aquariumId,
    required double min,
    required double max,
  }) async {
    final current = await repo.fetchThresholds(aquariumId);
    final updated = Threshold(
      tempMin: current.tempMin,
      tempMax: current.tempMax,
      turbidityMin: min,
      turbidityMax: max,
      phMin: current.phMin,
      phMax: current.phMax,
    );
    await repo.setThresholds(aquariumId, updated);
  }

  Future<void> setTurbidityNotification({
    required String aquariumId,
    required bool enabled,
  }) async {
    final current = await repo.fetchNotificationPrefs(aquariumId);
    await repo.setNotificationPrefs(
      aquariumId,
      current.copyWith(turbidity: enabled),
    );
  }
}

final turbidityViewModelProvider = Provider<TurbidityViewModel>((ref) {
  final repo = ref.watch(turbidityRepositoryProvider);
  return TurbidityViewModel(repo);
});
