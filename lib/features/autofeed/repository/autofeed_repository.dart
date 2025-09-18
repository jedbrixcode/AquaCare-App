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

  Future<bool> startManualFeeding() => _ws.startManualFeeding();
  Future<bool> stopManualFeeding() => _ws.stopManualFeeding();
  Future<bool> sendRotationFeeding(int rotations) =>
      _ws.sendRotationFeeding(rotations);
  void disconnect() => _ws.disconnect();
}
