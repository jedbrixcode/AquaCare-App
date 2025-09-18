import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/graphs/repository/graphs_repository.dart';
import 'package:aquacare_v5/core/models/sensor_log_point.dart';

enum GraphRange { hourly, weekly }

class SensorGraphsState {
  final String aquariumId;
  final GraphRange range;
  final AsyncValue<List<SensorLogPoint>> temperature;
  final AsyncValue<List<SensorLogPoint>> turbidity;
  final AsyncValue<List<SensorLogPoint>> ph;
  final AsyncValue<List<SensorLogPoint>> weekly;

  const SensorGraphsState({
    required this.aquariumId,
    required this.range,
    required this.temperature,
    required this.turbidity,
    required this.ph,
    required this.weekly,
  });

  SensorGraphsState copyWith({
    String? aquariumId,
    GraphRange? range,
    AsyncValue<List<SensorLogPoint>>? temperature,
    AsyncValue<List<SensorLogPoint>>? turbidity,
    AsyncValue<List<SensorLogPoint>>? ph,
    AsyncValue<List<SensorLogPoint>>? weekly,
  }) => SensorGraphsState(
    aquariumId: aquariumId ?? this.aquariumId,
    range: range ?? this.range,
    temperature: temperature ?? this.temperature,
    turbidity: turbidity ?? this.turbidity,
    ph: ph ?? this.ph,
    weekly: weekly ?? this.weekly,
  );

  factory SensorGraphsState.initial() => const SensorGraphsState(
    aquariumId: '1',
    range: GraphRange.hourly,
    temperature: AsyncData([]),
    turbidity: AsyncData([]),
    ph: AsyncData([]),
    weekly: AsyncData([]),
  );
}

class SensorGraphsViewModel extends StateNotifier<SensorGraphsState> {
  SensorGraphsViewModel(this._repo) : super(SensorGraphsState.initial()) {
    loadDaily();
  }

  final GraphsRepository _repo;

  void setAquarium(String id) {
    state = state.copyWith(aquariumId: id);
    if (state.range == GraphRange.hourly) {
      loadDaily();
    } else {
      loadWeekly();
    }
  }

  void setRange(GraphRange r) {
    state = state.copyWith(range: r);
    if (r == GraphRange.hourly) {
      loadDaily();
    } else {
      loadWeekly();
    }
  }

  Future<void> loadDaily() async {
    state = state.copyWith(
      temperature: const AsyncLoading(),
      turbidity: const AsyncLoading(),
      ph: const AsyncLoading(),
    );
    try {
      final temp = await _repo.fetchDaily('Temperature');
      final turb = await _repo.fetchDaily('Turbidity');
      final ph = await _repo.fetchDaily('PH');
      state = state.copyWith(
        temperature: AsyncData(temp),
        turbidity: AsyncData(turb),
        ph: AsyncData(ph),
      );
    } catch (e, st) {
      state = state.copyWith(
        temperature: AsyncError(e, st),
        turbidity: AsyncError(e, st),
        ph: AsyncError(e, st),
      );
    }
  }

  Future<void> loadWeekly() async {
    state = state.copyWith(weekly: const AsyncLoading());
    try {
      final weekly = await _repo.fetchWeeklyAverages();
      state = state.copyWith(weekly: AsyncData(weekly));
    } catch (e, st) {
      state = state.copyWith(weekly: AsyncError(e, st));
    }
  }
}

final sensorGraphsViewModelProvider =
    StateNotifierProvider<SensorGraphsViewModel, SensorGraphsState>((ref) {
      final repo = ref.watch(graphsRepositoryProvider);
      return SensorGraphsViewModel(repo);
    });
