import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/autofeed_repository.dart';

class AutoFeedState {
  final bool isManualMode;
  final int rotations;
  final bool isFeeding;
  final bool isCameraLoading;
  final bool isConnected;

  const AutoFeedState({
    required this.isManualMode,
    required this.rotations,
    required this.isFeeding,
    required this.isCameraLoading,
    required this.isConnected,
  });

  AutoFeedState copyWith({
    bool? isManualMode,
    int? rotations,
    bool? isFeeding,
    bool? isCameraLoading,
    bool? isConnected,
  }) => AutoFeedState(
    isManualMode: isManualMode ?? this.isManualMode,
    rotations: rotations ?? this.rotations,
    isFeeding: isFeeding ?? this.isFeeding,
    isCameraLoading: isCameraLoading ?? this.isCameraLoading,
    isConnected: isConnected ?? this.isConnected,
  );

  factory AutoFeedState.initial() => const AutoFeedState(
    isManualMode: false,
    rotations: 3,
    isFeeding: false,
    isCameraLoading: true,
    isConnected: false,
  );
}

class AutoFeedViewModel extends StateNotifier<AutoFeedState> {
  AutoFeedViewModel(this._repo, {required this.backendUrl})
    : super(AutoFeedState.initial());

  final AutoFeedRepository _repo;
  final String backendUrl;

  Future<void> connect(String aquariumId) async {
    final ok = await _repo.connectFeeder(
      backendUrl: backendUrl,
      aquariumId: aquariumId,
    );
    state = state.copyWith(isConnected: ok);
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

  Future<bool> startManual() async {
    final ok = await _repo.startManualFeeding();
    state = state.copyWith(isFeeding: ok);
    return ok;
  }

  Future<bool> stopManual() async {
    final ok = await _repo.stopManualFeeding();
    state = state.copyWith(isFeeding: !ok ? state.isFeeding : false);
    return ok;
  }

  Future<bool> sendRotation() async {
    return _repo.sendRotationFeeding(state.rotations);
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
