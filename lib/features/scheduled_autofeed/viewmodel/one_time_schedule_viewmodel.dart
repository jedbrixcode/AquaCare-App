import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/one_time_schedule_model.dart';
import '../repository/firestore_schedule_repository.dart';
import '../../../core/services/notifications_service.dart';

class OneTimeScheduleState {
  final List<OneTimeSchedule> schedules;
  final bool isLoading;
  final String? errorMessage;

  const OneTimeScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OneTimeScheduleState copyWith({
    List<OneTimeSchedule>? schedules,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OneTimeScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final firestoreScheduleRepositoryProvider =
    Provider<FirestoreScheduleRepository>(
      (ref) => FirestoreScheduleRepository(),
    );

class OneTimeScheduleViewModel extends StateNotifier<OneTimeScheduleState> {
  OneTimeScheduleViewModel(this._repo, this.aquariumId)
    : super(const OneTimeScheduleState()) {
    _init();
  }

  final FirestoreScheduleRepository _repo;
  final int aquariumId;
  StreamSubscription<List<OneTimeSchedule>>? _sub;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // prime from cache
      final cached = await _repo.getCachedSchedules(aquariumId);
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(schedules: cached);
      }

      _sub = _repo
          .getOneTimeSchedules(aquariumId)
          .listen(
            (items) {
              state = state.copyWith(schedules: items, isLoading: false);
              _scheduleNotifications(items);
            },
            onError: (e) async {
              final cached = await _repo.getCachedSchedules(aquariumId);
              state = state.copyWith(
                isLoading: false,
                errorMessage: e.toString(),
                schedules: cached ?? state.schedules,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _scheduleNotifications(List<OneTimeSchedule> items) {
    for (final s in items) {
      final at = s.scheduledAtLocal;
      if (at == null) continue;
      final now = DateTime.now();
      if (at.isBefore(now)) continue; // don't schedule past

      final pre = at.subtract(const Duration(hours: 1));
      if (pre.isAfter(now)) {
        NotificationsService().scheduleLocal(
          id: _notifId('${s.id}_pre'),
          scheduledAt: pre,
          title: 'Feeding soon',
          body:
              'Aquarium ${s.aquariumId}: ${s.food} x${s.cycle} at ${s.scheduleTime}',
        );
      }
      NotificationsService().scheduleLocal(
        id: _notifId('${s.id}_start'),
        scheduledAt: at,
        title: 'Feeding started',
        body: 'Aquarium ${s.aquariumId}: ${s.food} x${s.cycle}',
      );
    }
  }

  int _notifId(String key) => key.hashCode & 0x7fffffff;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final oneTimeScheduleViewModelProvider = StateNotifierProvider.family<
  OneTimeScheduleViewModel,
  OneTimeScheduleState,
  int
>((ref, aquariumId) {
  final repo = ref.watch(firestoreScheduleRepositoryProvider);
  return OneTimeScheduleViewModel(repo, aquariumId);
});
