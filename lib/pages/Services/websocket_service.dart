import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  late WebSocketChannel _channel;

  WebSocketService._internal();

  void connect({
    required Function(String type, String message) onNotificationReceived,
  }) {
    // Update this if your WebSocket runs on a different host/port
    final uri = Uri.parse('wss://aquacare-application.onrender.com/');

    _channel = WebSocketChannel.connect(uri);

    print('Connecting to WebSocket...');

    _channel.stream.listen(
      (message) {
        print('Received message: $message');

        final data = jsonDecode(message);

        if (data.containsKey("alertForPH")) {
          onNotificationReceived("PH", data["alertForPH"]);
        } else if (data.containsKey("alertForTemp")) {
          onNotificationReceived("Temperature", data["alertForTemp"]);
        } else if (data.containsKey("alertForTurb")) {
          onNotificationReceived("Turbidity", data["alertForTurb"]);
        } else {
          onNotificationReceived("General", message);
        }
      },
      onDone: () => print("WebSocket connection closed."),
      onError: (error) => print("WebSocket error: $error"),
    );
  }

  void sendTestMessage() {
    final message = jsonEncode({
      "PH": 9.5,
      "Temperature": 30.0,
      "Turbidity": 5.0,
    });
    _channel.sink.add(message);
    print('Sent test message: $message');
  }

  void disconnect() {
    _channel.sink.close();
    print('WebSocket disconnected.');
  }
}
