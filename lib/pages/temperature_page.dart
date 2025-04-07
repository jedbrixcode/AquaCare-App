import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:aquacare_v5/pages/Services/notif_service.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  bool isNotificationOn = false;
  int minTemp = 25;
  int maxTemp = 30;
  int? currentTemp;
  bool hasNotified = false;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _fetchTemperature();
  }

  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    "Sensors",
  );

  void _fetchTemperature() {
    _database.child("Temperature").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        int? newTemp = int.tryParse(data.toString());

        if (newTemp != null && newTemp != currentTemp) {
          setState(() {
            currentTemp = newTemp;
          });

          print("Fetched temp: $currentTemp");

          if (isNotificationOn &&
              (currentTemp! > maxTemp || currentTemp! < minTemp)) {
            if (!hasNotified) {
              _notificationService.showNotification(
                title: 'Temperature Alert!',
                body: 'Current temperature: $currentTemp°C is out of range.',
                payLoad: 'Out of range alert',
              );
              hasNotified = true;
            }
          } else {
            // Reset if temperature goes back to normal
            hasNotified = false;
          }
        }
      }
    });
  }

  Color getTemperatureColor() {
    if (currentTemp == null) return Colors.grey;
    if (currentTemp! > maxTemp) return Colors.red[500]!;
    if (currentTemp! < minTemp) return Colors.blue[500]!;
    return Colors.green[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Temperature", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Notification Toggle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "NOTIFICATION",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: isNotificationOn,
                    onChanged: (value) {
                      setState(() {
                        isNotificationOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Temperature Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _temperatureSelector(minTemp, (value) {
                  setState(() {
                    minTemp = value;
                  });
                }),
                const Text(" - "),
                _temperatureSelector(maxTemp, (value) {
                  setState(() {
                    maxTemp = value;
                  });
                }),
                const Text(
                  "°C",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    print("Temperature set: Min $minTemp°C, Max $maxTemp°C");
                  },
                  child: const Text("SET"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Static Temperature Display
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: getTemperatureColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "CURRENT TEMPERATURE: ${currentTemp ?? 'Loading...'}°C",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // Optional: Add functionality or leave empty
              },
              child: const Text("SET TO DEFAULT TEMPERATURE"),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const Text(
                  "Note: Default aquarium temperature for fishes are 26-28°C.",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _temperatureSelector(int value, Function(int) onChanged) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (value > 0) {
              onChanged(value - 1);
            }
          },
          icon: const Icon(Icons.arrow_drop_down),
        ),
        Text(value.toString(), style: const TextStyle(fontSize: 18)),
        IconButton(
          onPressed: () {
            onChanged(value + 1);
          },
          icon: const Icon(Icons.arrow_drop_up),
        ),
      ],
    );
  }
}
