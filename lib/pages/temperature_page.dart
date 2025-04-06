// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  // define database inside state class
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    "Sensors",
  );

  bool isNotificationOn = false;
  int minTemp = 25;
  int maxTemp = 30;
  int?
  currentTemp; // This will be updated from the sensor, not modified manually

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
  }

  // kaartehan
  Color getTemperatureColor() {
    if (currentTemp == null) {
      return Colors.grey; // Neutral color if temp is not available
    }

    if (currentTemp! > maxTemp) {
      return Colors.red[700]!; // Hot temp
    } else if (currentTemp! < minTemp) {
      return Colors.blue[400]!; // Cold temp
    } else {
      return Colors.green[300]!; // Optimal temp
    }
  }

  // real-time update for temps
  void _fetchTemperature() {
    _database.child("Temperature").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          currentTemp = int.tryParse(data.toString()) ?? 0;
        });
      }
    });
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
              padding: EdgeInsets.all(10),
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

                // Set User Preference Button
                ElevatedButton(
                  onPressed: () {
                    print("Temperature set: Min $minTemp°C, Max $maxTemp°C");
                  },
                  child: const Text("SET"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current Temperature Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: getTemperatureColor(), // Ensure this updates
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Current Temperature: ${currentTemp ?? 'Loading...'}°C",
                    ),
                  ),
                );
              },
              child: Text(
                "CURRENT TEMPERATURE: ${currentTemp ?? 'Loading...'}°C",
              ), // Should always update
            ),
            const SizedBox(height: 10),

            // Default Temperature Value Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // Keeping it neutral
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Default temperature for aquariums is set.'),
                  ),
                );
              },
              child: Text("SET TO DEFAULT TEMPERATURE"),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Note: Default aquarium temperature for fishes are 26-28°C.",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 30),
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
