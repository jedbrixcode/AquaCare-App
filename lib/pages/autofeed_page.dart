import 'package:flutter/material.dart';
import 'package:aquacare_v5/pages/Services/websocket_service.dart';

class AutoFeedingPage extends StatefulWidget {
  const AutoFeedingPage({super.key});

  @override
  State<AutoFeedingPage> createState() => _AutoFeedingPageState();
}

class _AutoFeedingPageState extends State<AutoFeedingPage> {
  final WebSocketService _webSocketService = WebSocketService();

  String status = "Not connected";

  void _connectWebSocket() {
    _webSocketService.connect(
      onNotificationReceived: (type, message) {
        setState(() {
          status = "[$type] $message";
        });
        print("[$type] $message");
      },
    );
    _webSocketService.sendTestMessage();
    setState(() {
      status = "WebSocket connected. Test message sent.";
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Automatic Feeding"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _connectWebSocket,
              child: const Text(
                "Test WebSocket Connection",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
