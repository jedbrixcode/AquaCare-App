import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feeding_schedule_model.dart';
import '../repository/scheduled_autofeed_repository.dart';

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
    loadData();
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
      final schedules = await _repository.getFeedingSchedules(aquariumId);
      final autoFeederStatus = await _repository.getAutoFeederStatus(
        aquariumId,
      );

      state = state.copyWith(
        schedules: schedules,
        autoFeederStatus: autoFeederStatus,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addSchedule({
    required String time,
    required int cycles,
    required String foodType,
    required bool isEnabled,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final newSchedule = await _repository.addFeedingSchedule(
        aquariumId: aquariumId,
        time: time,
        cycles: cycles,
        foodType: foodType,
        isEnabled: isEnabled,
      );

      final updatedSchedules = [...state.schedules, newSchedule];
      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
      // Cache after successful write (stub)
      _repository.cacheSchedules(aquariumId, updatedSchedules).ignore();
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
        await _repository.deleteFeedingSchedule(
          aquariumId: aquariumId,
          scheduleId: scheduleId,
        );
        final created = await _repository.addFeedingSchedule(
          aquariumId: aquariumId,
          time: time,
          cycles: cycles,
          foodType: foodType,
          isEnabled: isEnabled,
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

      final updated = existing.copyWith(cycles: cycles, isEnabled: isEnabled);
      final updatedSchedules =
          state.schedules.map((s) => s.id == scheduleId ? updated : s).toList();
      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
      _repository.cacheSchedules(aquariumId, updatedSchedules).ignore();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: scheduleId,
      );

      final updatedSchedules =
          state.schedules
              .where((schedule) => schedule.id != scheduleId)
              .toList();
      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
      _repository.cacheSchedules(aquariumId, updatedSchedules).ignore();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleSchedule(String scheduleId, bool isEnabled) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.toggleFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: scheduleId,
        isEnabled: isEnabled,
      );
      final updatedSchedules =
          state.schedules
              .map(
                (s) =>
                    s.id == scheduleId ? s.copyWith(isEnabled: isEnabled) : s,
              )
              .toList();
      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
      _repository.cacheSchedules(aquariumId, updatedSchedules).ignore();
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
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.addOneTimeTask(
        aquariumId: aquariumId,
        scheduleDateTime: scheduleDateTime,
        cycles: cycles,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteOneTimeTask({required DateTime scheduleDateTime}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteOneTimeTask(
        aquariumId: aquariumId,
        scheduleDateTime: scheduleDateTime,
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
