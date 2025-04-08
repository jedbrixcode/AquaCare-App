import 'package:flutter/material.dart';
import 'package:aquacare_v5/pages/Services/socket_service.dart';

class AutoFeedingPage extends StatefulWidget {
  const AutoFeedingPage({super.key});

  @override
  State<AutoFeedingPage> createState() => _AutoFeedingPageState();
}

class _AutoFeedingPageState extends State<AutoFeedingPage> {
  @override
  void initState() {
    super.initState();
    SocketService().initSocket((type, message) {
      print("[$type Notification] $message");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Feeding"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            SocketService().sendTestMessage(); // Sends to the backend
          },
          child: const Text(
            "Test WebSocket Connection",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
