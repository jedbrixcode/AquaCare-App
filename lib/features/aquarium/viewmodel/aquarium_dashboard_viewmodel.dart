import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/models/notification_model.dart';
import '../repository/aquarium_repository.dart';
import 'dart:async';

final aquariumRepositoryProvider = Provider<AquariumRepository>(
  (ref) => AquariumRepository(),
);

/// Stream of all aquariums with their name and sensor data
final aquariumsSummaryProvider = StreamProvider<List<AquariumSummary>>((ref) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.getAllAquariumsSummary();
});

/// Provider for a specific aquarium's sensor data
final aquariumSensorProvider = StreamProvider.family<Sensor, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.sensorStream(aquariumId);
});

/// Provider for a specific aquarium's thresholds
final aquariumThresholdProvider = FutureProvider.family<Threshold, String>((
  ref,
  aquariumId,
) async {
  final repo = ref.watch(aquariumRepositoryProvider);
  return await repo.fetchThresholds(aquariumId);
});

/// Provider for a specific aquarium's notification preferences
final aquariumNotificationProvider =
    FutureProvider.family<NotificationPref, String>((ref, aquariumId) async {
      final repo = ref.watch(aquariumRepositoryProvider);
      return await repo.fetchNotificationPrefs(aquariumId);
    });

/// Provider for a specific aquarium's auto-light status (live)
final aquariumAutoLightProvider = StreamProvider.family<bool, String>((
  ref,
  aquariumId,
) {
  final repo = ref.watch(aquariumRepositoryProvider);
  return repo.getAutoLightStatus(aquariumId);
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

// Controller ViewModel to handle dashboard actions and expose transient messages
class AquariumDashboardController extends StateNotifier<AsyncValue<void>> {
  AquariumDashboardController(this.repo) : super(const AsyncData(null));

  final AquariumRepository repo;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messages => _messageController.stream;

  Future<bool> createAquarium(String name) async {
    state = const AsyncLoading();
    try {
      await repo.createAquarium(name);
      _messageController.add('Aquarium "$name" created successfully!');
      state = const AsyncData(null);
      return true;
    } catch (e) {
      _messageController.add('Error creating aquarium: $e');
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateAquariumName(String aquariumId, String newName) async {
    state = const AsyncLoading();
    try {
      await repo.updateAquariumName(aquariumId, newName);
      _messageController.add('Aquarium renamed to "$newName" successfully!');
      state = const AsyncData(null);
      return true;
    } catch (e) {
      _messageController.add('Error updating aquarium: $e');
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteAquarium(String aquariumId) async {
    state = const AsyncLoading();
    try {
      await repo.deleteAquarium(aquariumId);
      _messageController.add('Aquarium deleted successfully!');
      state = const AsyncData(null);
      return true;
    } catch (e) {
      _messageController.add('Error deleting aquarium: $e');
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateNotificationSettings(
    String aquariumId,
    bool temperature,
    bool turbidity,
    bool ph,
  ) async {
    state = const AsyncLoading();
    try {
      await repo.updateNotificationSettings(
        aquariumId,
        temperature,
        turbidity,
        ph,
      );
      _messageController.add('Notification settings updated successfully!');
      state = const AsyncData(null);
      return true;
    } catch (e) {
      _messageController.add('Error updating notification settings: $e');
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> isAquariumNameExists(String name, {String? excludeId}) {
    return repo.isAquariumNameExists(name, excludeId: excludeId);
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}

final aquariumDashboardControllerProvider =
    StateNotifierProvider<AquariumDashboardController, AsyncValue<void>>((ref) {
      final repo = ref.watch(aquariumRepositoryProvider);
      return AquariumDashboardController(repo);
    });
