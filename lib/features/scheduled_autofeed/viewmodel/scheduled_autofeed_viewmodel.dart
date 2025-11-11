import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feeding_schedule_model.dart';
import '../models/one_time_schedule_model.dart';
import '../repository/scheduled_autofeed_repository.dart';
import '../repository/firestore_schedule_repository.dart';

// Repository provider
final scheduledAutofeedRepositoryProvider =
    Provider<ScheduledAutofeedRepository>((ref) {
      return ScheduledAutofeedRepository();
    });

// State class
class ScheduledAutofeedState {
  final List<FeedingSchedule> schedules;
  final AutoFeederStatus? autoFeederStatus;
  final bool isLoading;
  final String? errorMessage;

  const ScheduledAutofeedState({
    this.schedules = const [],
    this.autoFeederStatus,
    this.isLoading = false,
    this.errorMessage,
  });

  ScheduledAutofeedState copyWith({
    List<FeedingSchedule>? schedules,
    AutoFeederStatus? autoFeederStatus,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScheduledAutofeedState(
      schedules: schedules ?? this.schedules,
      autoFeederStatus: autoFeederStatus ?? this.autoFeederStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ViewModel
class ScheduledAutofeedViewModel extends StateNotifier<ScheduledAutofeedState> {
  final ScheduledAutofeedRepository _repository;
  final String aquariumId;
  Stream<List<FeedingSchedule>>? _schedulesStream;
  Stream<AutoFeederStatus>? _statusStream;

  ScheduledAutofeedViewModel(this._repository, this.aquariumId)
    : super(const ScheduledAutofeedState()) {
    // Kick off initial load and subscribe to realtime updates (RTDB + Firestore)
    loadData();
    // Ensure we actually listen to backend-written updates instead of relying on local state
    // to keep UI in sync with Firestore/RTDB.
    // ignore: discarded_futures
    initialize();
  }

  // Initialize realtime subscriptions and optional cache prefill
  Future<void> initialize() async {
    // Prefill from local cache (stub - to be implemented in repository/local service)
    try {
      final cached = await _repository.getCachedSchedules(aquariumId);
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(schedules: cached);
      }
    } catch (_) {}

    // Subscribe to realtime streams if available
    _schedulesStream = _repository.subscribeSchedules(aquariumId);
    _statusStream = _repository.subscribeAutoFeederStatus(aquariumId);

    _schedulesStream?.listen((items) {
      state = state.copyWith(schedules: items);
    });
    _statusStream?.listen((status) {
      state = state.copyWith(autoFeederStatus: status);
    });
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Daily schedules from RTDB
      final daily = await _repository.getFeedingSchedules(aquariumId);

      // 2. One-time schedules from Firestore
      final oneTimeRepo = FirestoreScheduleRepository();
      final oneTimeStream = oneTimeRepo.getOneTimeSchedules(
        int.tryParse(aquariumId) ?? 0,
      );
      final oneTime =
          await oneTimeStream.first; // one-time fetch (initial load)

      // 3. Merge results
      final merged = [
        ...daily, // daily (RTDB)
        ...oneTime.map(fromOneTime), // convert Firestore to FeedingSchedule
      ];

      // 4. Sort all by time
      merged.sort((a, b) => a.time.compareTo(b.time));

      state = state.copyWith(schedules: merged, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  FeedingSchedule fromOneTime(OneTimeSchedule o) {
    final parts = o.scheduleTime.split(' ');
    String hhmm = '00:00';
    if (parts.length >= 2) {
      final timeParts = parts[1].split(':');
      if (timeParts.length >= 2) hhmm = '${timeParts[0]}:${timeParts[1]}';
    }
    return FeedingSchedule(
      id: o.id,
      aquariumId: o.aquariumId.toString(),
      time: hhmm,
      cycles: o.cycle,
      foodType: o.food,
      isEnabled: o.status == 'pending' || o.status == 'running',
      daily: false,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  Future<void> addSchedule({
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.addFeedingSchedule(
        aquariumId: aquariumId,
        time: time,
        cycles: cycles,
        foodType: foodType,
        isEnabled: isEnabled,
      );
      // After backend writes into Firebase/Firestore, reload from source of truth
      await loadData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final existing = state.schedules.firstWhere((s) => s.id == scheduleId);
      final bool timeChanged = existing.time != time;
      final bool foodChanged = existing.foodType != foodType;
      if (timeChanged || foodChanged) {
        // Delete old schedule by its time (backend expects time in URL)
        await _repository.deleteFeedingSchedule(
          aquariumId: aquariumId,
          scheduleId: existing.time,
        );
        // Recreate with same daily flag
        final created = await _repository.addFeedingSchedule(
          aquariumId: aquariumId,
          time: time,
          cycles: cycles,
          foodType: foodType,
          isEnabled: isEnabled,
          daily: existing.daily,
        );
        final replaced =
            state.schedules.where((s) => s.id != scheduleId).toList()
              ..add(created);
        state = state.copyWith(schedules: replaced, isLoading: false);
        _repository.cacheSchedules(aquariumId, replaced).ignore();
        return;
      }

      if (existing.cycles != cycles) {
        await _repository.updateCycle(
          aquariumId: aquariumId,
          time: time,
          cycles: cycles,
        );
      }
      if (existing.isEnabled != isEnabled) {
        await _repository.updateSwitch(
          aquariumId: aquariumId,
          time: time,
          isEnabled: isEnabled,
        );
      }
      // Reload from Firebase/Firestore to reflect backend-updated values
      await loadData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final existing = state.schedules.firstWhere((s) => s.id == scheduleId);
      await _repository.deleteFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: existing.time, // backend expects time in URL
      );
      // Reload from Firebase/Firestore after deletion
      await loadData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleSchedule(String scheduleId, bool isEnabled) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final existing = state.schedules.firstWhere((s) => s.id == scheduleId);
      await _repository.toggleFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: existing.time, // backend expects time in URL
        isEnabled: isEnabled,
      );
      // Reload to ensure UI reflects backend/RTDB state
      await loadData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleAutoFeeder(bool isEnabled) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedStatus = await _repository.toggleAutoFeeder(
        aquariumId: aquariumId,
        isEnabled: isEnabled,
      );

      state = state.copyWith(autoFeederStatus: updatedStatus, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // One-time task API
  Future<void> addOneTimeTask({
    required DateTime scheduleDateTime,
    required int cycles,
    required String food,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.addOneTimeTask(
        aquariumId: aquariumId,
        scheduleDateTime: scheduleDateTime,
        cycles: cycles,
        food: food,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteOneTimeTask({
    required DateTime scheduleDateTime,
    String? documentId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteOneTimeTask(
        aquariumId: aquariumId,
        scheduleDateTime: scheduleDateTime,
        documentId: documentId,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// Provider
final scheduledAutofeedViewModelProvider = StateNotifierProvider.family<
  ScheduledAutofeedViewModel,
  ScheduledAutofeedState,
  String
>((ref, aquariumId) {
  final repository = ref.watch(scheduledAutofeedRepositoryProvider);
  return ScheduledAutofeedViewModel(repository, aquariumId);
});
