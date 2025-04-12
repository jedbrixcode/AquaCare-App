import 'package:flutter/material.dart';
import 'package:aquacare_v5/pages/Services/notif_service.dart'; // make sure this is the correct path

class AutoLightPage extends StatefulWidget {
  const AutoLightPage({super.key});

  @override
  State<AutoLightPage> createState() => _AutoLightPageState();
}

class _AutoLightPageState extends State<AutoLightPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Light"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("dito mga auto lights"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NotificationService().showNotification(
                  title: "Manual Test",
                  body: "Notification triggered manually 🚨",
                  payLoad: "manual_payload",
                );
              },
              child: Text("Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
