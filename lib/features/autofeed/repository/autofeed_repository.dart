import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aquacare_v5/core/services/websocket_service.dart';

class AutoFeedRepository {
  AutoFeedRepository({http.Client? client, WebSocketService? ws})
    : _client = client ?? http.Client(),
      _ws = ws ?? WebSocketService.instance;

  final http.Client _client;
  final WebSocketService _ws;

  Future<void> toggleCamera({
    required String backendUrl,
    required String aquariumId,
    required bool on,
  }) async {
    final url = Uri.parse('$backendUrl/aquarium/$aquariumId/camera_switch/$on');
    await _client.post(url);
  }

  Future<bool> connectFeeder({
    required String backendUrl,
    required String aquariumId,
  }) async {
    return _ws.connectToFeeder(aquariumId, backendUrl);
  }

  bool get isWsConnected => _ws.isConnected;

  Future<bool> startManualFeeding({
    required String backendUrl,
    required String aquariumId,
  }) async {
    final url = Uri.parse('$backendUrl/aquarium/$aquariumId/manual/hold_feed');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'food': 'pellet'}),
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
  }) async {
    final url = Uri.parse(
      '$backendUrl/aquarium/$aquariumId/manual/rotation_feed',
    );
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'food': 'pellet', 'rotations': rotations.toString()}),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  void disconnect() => _ws.disconnect();
}
