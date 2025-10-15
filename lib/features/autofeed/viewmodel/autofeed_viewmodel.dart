import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/autofeed_repository.dart';

class AutoFeedState {
  final bool isManualMode;
  final int rotations;
  final bool isFeeding;
  final bool isCameraLoading;
  final bool isConnected;
  final String food; // 'pellet' or 'flakes'

  const AutoFeedState({
    required this.isManualMode,
    required this.rotations,
    required this.isFeeding,
    required this.isCameraLoading,
    required this.isConnected,
    required this.food,
  });

  AutoFeedState copyWith({
    bool? isManualMode,
    int? rotations,
    bool? isFeeding,
    bool? isCameraLoading,
    bool? isConnected,
    String? food,
  }) => AutoFeedState(
    isManualMode: isManualMode ?? this.isManualMode,
    rotations: rotations ?? this.rotations,
    isFeeding: isFeeding ?? this.isFeeding,
    isCameraLoading: isCameraLoading ?? this.isCameraLoading,
    isConnected: isConnected ?? this.isConnected,
    food: food ?? this.food,
  );

  factory AutoFeedState.initial() => const AutoFeedState(
    isManualMode: false,
    rotations: 3,
    isFeeding: false,
    isCameraLoading: true,
    isConnected: false,
    food: 'pellet',
  );
}

class AutoFeedViewModel extends StateNotifier<AutoFeedState> {
  AutoFeedViewModel(this._repo, {required this.backendUrl})
    : super(AutoFeedState.initial());

  final AutoFeedRepository _repo;
  final String backendUrl;

  bool? get isConnected => null;

  Future<void> connect(String aquariumId) async {
    final ok = await _repo.connectFeeder(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
    );
    state = state.copyWith(isConnected: ok);
  }

  void updateConnectionStatus() {
    state = state.copyWith(isConnected: _repo.isWsConnected);
  }

  Future<void> toggleCamera(String aquariumId, bool on) async {
    await _repo.toggleCamera(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
      on: on,
    );
  }

  void setManualMode(bool manual) {
    state = state.copyWith(isManualMode: manual);
  }

  void setRotations(int r) {
    state = state.copyWith(rotations: r);
  }

  void setFood(String f) {
    final validFoods = ['pellet', 'flakes'];
    final normalized = f.toLowerCase();
    if (validFoods.contains(normalized)) {
      state = state.copyWith(food: normalized);
    } else {
      print('Invalid food type: $f');
    }
  }

  Future<bool> startManual(String aquariumId) async {
    final ok = await _repo.startManualFeeding(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
      food: state.food,
    );
    state = state.copyWith(isFeeding: ok);
    return ok;
  }

  Future<bool> stopManual(String aquariumId) async {
    final ok = await _repo.stopManualFeeding(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
    );
    state = state.copyWith(isFeeding: !ok ? state.isFeeding : false);
    return ok;
  }

  Future<bool> sendRotation(String aquariumId) async {
    return _repo.sendRotationFeeding(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
      rotations: state.rotations,
      food: state.food,
    );
  }

  void disconnect() => _repo.disconnect();
}

final autoFeedViewModelProvider =
    StateNotifierProvider.family<AutoFeedViewModel, AutoFeedState, String>((
      ref,
      backendUrl,
    ) {
      return AutoFeedViewModel(AutoFeedRepository(), backendUrl: backendUrl);
    });
