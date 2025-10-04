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

  ScheduledAutofeedViewModel(this._repository, this.aquariumId)
    : super(const ScheduledAutofeedState()) {
    loadData();
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
      final updatedSchedule = await _repository.updateFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: scheduleId,
        time: time,
        cycles: cycles,
        foodType: foodType,
        isEnabled: isEnabled,
      );

      final updatedSchedules =
          state.schedules.map((schedule) {
            return schedule.id == scheduleId ? updatedSchedule : schedule;
          }).toList();

      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
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
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleSchedule(String scheduleId, bool isEnabled) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedSchedule = await _repository.toggleFeedingSchedule(
        aquariumId: aquariumId,
        scheduleId: scheduleId,
        isEnabled: isEnabled,
      );

      final updatedSchedules =
          state.schedules.map((schedule) {
            return schedule.id == scheduleId ? updatedSchedule : schedule;
          }).toList();

      state = state.copyWith(schedules: updatedSchedules, isLoading: false);
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
