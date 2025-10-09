import 'dart:async';

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
  final AsyncValue<List<String>> aquariumNames;

  const SensorGraphsState({
    required this.aquariumId,
    required this.range,
    required this.temperature,
    required this.turbidity,
    required this.ph,
    required this.weekly,
    required this.aquariumNames,
  });

  SensorGraphsState copyWith({
    String? aquariumId,
    GraphRange? range,
    AsyncValue<List<SensorLogPoint>>? temperature,
    AsyncValue<List<SensorLogPoint>>? turbidity,
    AsyncValue<List<SensorLogPoint>>? ph,
    AsyncValue<List<SensorLogPoint>>? weekly,
    AsyncValue<List<String>>? aquariumNames,
  }) => SensorGraphsState(
    aquariumId: aquariumId ?? this.aquariumId,
    range: range ?? this.range,
    temperature: temperature ?? this.temperature,
    turbidity: turbidity ?? this.turbidity,
    ph: ph ?? this.ph,
    weekly: weekly ?? this.weekly,
    aquariumNames: aquariumNames ?? this.aquariumNames,
  );

  factory SensorGraphsState.initial() => const SensorGraphsState(
    aquariumId: '1',
    range: GraphRange.hourly,
    temperature: AsyncData([]),
    turbidity: AsyncData([]),
    ph: AsyncData([]),
    weekly: AsyncData([]),
    aquariumNames: AsyncData([]),
  );
}

class SensorGraphsViewModel extends StateNotifier<SensorGraphsState> {
  SensorGraphsViewModel(this._repo) : super(SensorGraphsState.initial()) {
    // Ensure we have a name->ID map available for dropdown selections
    loadAquariumNames();
    // Begin listening for name updates (UI list), but do not override the selected ID improperly
    listenAquariumNames();
    // Load initial graphs for the default aquarium ID
    loadDaily();
  }

  final GraphsRepository _repo;
  late final StreamSubscription<List<String>> _aquariumSub;
  Map<String, String> _nameToId = {};
  Map<String, String> get nameToId => _nameToId;

  void listenAquariumNames() {
    _aquariumSub = _repo.fetchAquariumNamesStream().listen((names) {
      state = state.copyWith(aquariumNames: AsyncData(names));
      // If current aquariumId is not present in the known IDs, fallback to the first by name
      if (_nameToId.isNotEmpty &&
          !_nameToId.values.contains(state.aquariumId) &&
          names.isNotEmpty) {
        setAquariumByName(names.first);
      }
    });
  }

  void setAquarium(String id) {
    state = state.copyWith(aquariumId: id);
    print('Selected aquarium: ${state.aquariumId}');
    if (state.range == GraphRange.hourly) {
      loadDaily();
    } else {
      loadWeekly();
    }
  }

  void setAquariumByName(String name) {
    final id = _nameToId[name];
    if (id != null) {
      setAquarium(id);
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

  Future<void> loadAquariumNames() async {
    state = state.copyWith(aquariumNames: const AsyncLoading());
    try {
      final map = await _repo.fetchAquariumIdNameMap(); // returns Map<name, id>
      _nameToId = map;
      state = state.copyWith(aquariumNames: AsyncData(map.keys.toList()));

      // Set default aquarium ID if not set
      if (state.aquariumId.isEmpty && map.isNotEmpty) {
        setAquarium(map.values.first); // Firebase ID
      }
    } catch (e, st) {
      state = state.copyWith(aquariumNames: AsyncError(e, st));
    }
  }

  Future<void> loadDaily() async {
    state = state.copyWith(
      temperature: const AsyncLoading(),
      turbidity: const AsyncLoading(),
      ph: const AsyncLoading(),
    );
    try {
      final temp = await _repo.fetchDaily('Temperature', state.aquariumId);
      final turb = await _repo.fetchDaily('Turbidity', state.aquariumId);
      final ph = await _repo.fetchDaily('PH', state.aquariumId);
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
      final weekly = await _repo.fetchWeeklyAverages(state.aquariumId);
      state = state.copyWith(weekly: AsyncData(weekly));
    } catch (e, st) {
      state = state.copyWith(weekly: AsyncError(e, st));
    }
  }

  @override
  void dispose() {
    _aquariumSub.cancel();
    super.dispose();
  }
}

final sensorGraphsViewModelProvider =
    StateNotifierProvider<SensorGraphsViewModel, SensorGraphsState>((ref) {
      final repo = ref.watch(graphsRepositoryProvider);
      return SensorGraphsViewModel(repo);
    });
