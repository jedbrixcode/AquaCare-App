import 'dart:convert';
import 'package:http/http.dart' as http;

class AutoFeedRepository {
  AutoFeedRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> toggleCamera({
    required String backendUrl,
    required String aquariumId,
    required bool on,
  }) async {
    final onParam = on ? 'True' : 'False';
    final url = Uri.parse(
      '$backendUrl/aquarium/$aquariumId/camera_switch/$onParam',
    );
    await _client.post(url);
  }

  Future<bool> connectFeeder({
    required String backendUrl,
    required String aquariumId,
  }) async {
    // WebSocket removed; treat connectivity as HTTP-only for now
    // Optionally, perform a lightweight HTTP check here if available
    return true;
  }

  bool get isWsConnected => true;

  Future<bool> startManualFeeding({
    required String backendUrl,
    required String aquariumId,
    required String food,
  }) async {
    final url = Uri.parse('$backendUrl/aquarium/$aquariumId/manual/hold_feed');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'food': food}),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> stopManualFeeding({
    required String backendUrl,
    required String aquariumId,
  }) async {
    // No explicit stop endpoint provided; treat release as client-side state only
    return true;
  }

  Future<bool> sendRotationFeeding({
    required String backendUrl,
    required String aquariumId,
    required int rotations,
    required String food,
  }) async {
    final url = Uri.parse('$backendUrl/aquarium/$aquariumId/manual/cycle_feed');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'food': food, 'cycles': rotations.toString()}),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  void disconnect() {}
}

class CameraState {
  final bool isCameraOn;

  CameraState({this.isCameraOn = false});

  CameraState copyWith({bool? isCameraOn}) {
    return CameraState(isCameraOn: isCameraOn ?? this.isCameraOn);
  }
}
