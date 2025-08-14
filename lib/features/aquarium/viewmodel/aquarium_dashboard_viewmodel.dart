import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';
import '../repository/aquarium_repository.dart';

final aquariumRepositoryProvider = Provider((ref) => AquariumRepository());

// Stream of all aquariums with their name and sensor data
final aquariumsSummaryProvider = StreamProvider<List<AquariumSummary>>((ref) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.getAllAquariumsSummary();
});

// Provider for a specific aquarium's sensor data
final aquariumSensorProvider = StreamProvider.family<Sensor, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.sensorStream(aquariumId);
});

// Provider for a specific aquarium's thresholds
final aquariumThresholdProvider = FutureProvider.family<Threshold, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(aquariumRepositoryProvider);
  return await repo.fetchThresholds(aquariumId);
});

// Provider for a specific aquarium's notification preferences
final aquariumNotificationProvider =
    FutureProvider.family<NotificationPref, String>((ref, aquariumId) async {
      final repo = ref.watch(aquariumRepositoryProvider);
      return await repo.fetchNotificationPrefs(aquariumId);
    });

class AquariumDashboardViewModel {
  final AquariumRepository repo;
  AquariumDashboardViewModel(this.repo);

  Future<void> setThresholds(String aquariumId, Threshold t) =>
      repo.setThresholds(aquariumId, t);
  Future<void> setNotificationPrefs(String aquariumId, NotificationPref n) =>
      repo.setNotificationPrefs(aquariumId, n);

  // CRUD Operations
  Future<String> createAquarium(String name) => repo.createAquarium(name);
  Future<void> updateAquariumName(String aquariumId, String newName) =>
      repo.updateAquariumName(aquariumId, newName);
  Future<void> deleteAquarium(String aquariumId) =>
      repo.deleteAquarium(aquariumId);
  Future<void> updateNotificationSettings(
    String aquariumId,
    bool temperature,
    bool turbidity,
    bool ph,
  ) => repo.updateNotificationSettings(aquariumId, temperature, turbidity, ph);
  Future<bool> isAquariumNameExists(String name, {String? excludeId}) =>
      repo.isAquariumNameExists(name, excludeId: excludeId);
}

final aquariumDashboardViewModelProvider = Provider<AquariumDashboardViewModel>(
  (ref) {
    final repo = ref.watch(aquariumRepositoryProvider);
    return AquariumDashboardViewModel(repo);
  },
);
