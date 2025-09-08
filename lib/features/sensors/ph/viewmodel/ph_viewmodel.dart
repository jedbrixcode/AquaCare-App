import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';

class PhRange {
  final double min;
  final double max;
  const PhRange({required this.min, required this.max});
}

final phRepositoryProvider = Provider<AquariumRepository>((ref) {
  return AquariumRepository();
});

final phValueProvider = StreamProvider.family<double, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(phRepositoryProvider);
  return repo.sensorStream(aquariumId).map((s) => s.ph);
});

final phThresholdProvider = FutureProvider.family<PhRange, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(phRepositoryProvider);
  final t = await repo.fetchThresholds(aquariumId);
  return PhRange(min: t.phMin, max: t.phMax);
});

final phNotificationProvider = FutureProvider.family<bool, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(phRepositoryProvider);
  final n = await repo.fetchNotificationPrefs(aquariumId);
  return n.ph;
});

class PhViewModel {
  final AquariumRepository repo;
  PhViewModel(this.repo);

  Future<void> setPhRange({
    required String aquariumId,
    required double min,
    required double max,
  }) async {
    final current = await repo.fetchThresholds(aquariumId);
    final updated = Threshold(
      tempMin: current.tempMin,
      tempMax: current.tempMax,
      turbidityMin: current.turbidityMin,
      turbidityMax: current.turbidityMax,
      phMin: min,
      phMax: max,
    );
    await repo.setThresholds(aquariumId, updated);
  }

  Future<void> setPhNotification({
    required String aquariumId,
    required bool enabled,
  }) async {
    final current = await repo.fetchNotificationPrefs(aquariumId);
    await repo.setNotificationPrefs(aquariumId, current.copyWith(ph: enabled));
  }
}

final phViewModelProvider = Provider<PhViewModel>((ref) {
  final repo = ref.watch(phRepositoryProvider);
  return PhViewModel(repo);
});
