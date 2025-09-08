import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  WebSocketChannel? _channel;
  String? _currentAquariumId;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get currentAquariumId => _currentAquariumId;

  /// Connect to the TankPi feeder WebSocket
  Future<bool> connectToFeeder(String aquariumId, String backendUrl) async {
    try {
      // Close existing connection if any
      await disconnect();

      final uri = Uri.parse(
        'ws://$backendUrl/aquarium/$aquariumId/feeder_switch',
      );
      _channel = WebSocketChannel.connect(uri);

      _currentAquariumId = aquariumId;
      _isConnected = true;

      // Listen for connection status
      _channel!.ready
          .then((_) {
            print('Connected to TankPi feeder for aquarium $aquariumId');
          })
          .catchError((error) {
            print('Failed to connect to TankPi feeder: $error');
            _isConnected = false;
          });

      return true;
    } catch (e) {
      print('Error connecting to TankPi feeder: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Send feeding command to TankPi
  Future<bool> sendFeedingCommand({
    required String status, // 'active', 'inactive', 'completed'
    int? rotations,
  }) async {
    if (!_isConnected || _channel == null) {
      print('Not connected to TankPi feeder');
      return false;
    }

    try {
      final message = {
        'status': status,
        if (rotations != null) 'rotations': rotations,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(jsonEncode(message));
      print('Sent feeding command to TankPi: $message');
      return true;
    } catch (e) {
      print('Error sending feeding command: $e');
      return false;
    }
  }

  /// Send auto-feeder toggle command
  Future<bool> toggleAutoFeeder(bool isActive) async {
    return await sendFeedingCommand(status: isActive ? 'active' : 'inactive');
  }

  /// Send manual feeding command (press and hold)
  Future<bool> startManualFeeding() async {
    return await sendFeedingCommand(status: 'active');
  }

  /// Stop manual feeding
  Future<bool> stopManualFeeding() async {
    return await sendFeedingCommand(status: 'inactive');
  }

  /// Send rotation feeding command
  Future<bool> sendRotationFeeding(int rotations) async {
    return await sendFeedingCommand(status: 'completed', rotations: rotations);
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    if (_channel != null) {
      try {
        await _channel!.sink.close(status.goingAway);
      } catch (e) {
        print('Error closing WebSocket: $e');
      }
      _channel = null;
    }
    _isConnected = false;
    _currentAquariumId = null;
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
