import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';
import '../repository/aquarium_repository.dart';

final aquariumRepositoryProvider = Provider((ref) => AquariumRepository());

final sensorProvider = StreamProvider<Sensor>((ref) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.sensorStream();
});

final thresholdProvider = FutureProvider<Threshold>((ref) async {
  final repo = ref.watch(aquariumRepositoryProvider);
  return await repo.fetchThresholds();
});

final notificationPrefProvider = FutureProvider<NotificationPref>((ref) async {
  final repo = ref.watch(aquariumRepositoryProvider);
  return await repo.fetchNotificationPrefs();
});

class AquariumDashboardViewModel {
  // For imperative updates (e.g., from UI actions)
  final AquariumRepository repo;
  AquariumDashboardViewModel(this.repo);

  Future<void> setThresholds(Threshold t) => repo.setThresholds(t);
  Future<void> setNotificationPrefs(NotificationPref n) =>
      repo.setNotificationPrefs(n);
}
