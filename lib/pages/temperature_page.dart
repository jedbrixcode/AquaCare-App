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
  double? currentTemp;

  final NotificationService _notificationService = NotificationService();

  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    "Sensors",
  );

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _fetchTemperature();
    _fetchTemperaturePreferences();
  }

  void _fetchTemperature() {
    _database.child("Temperature").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double? newTemp = double.tryParse(data.toString())?.toDouble();
        if (newTemp != null) {
          if (mounted) {
            setState(() {
              currentTemp = newTemp;
            });
          }
          print("Fetched temp: $currentTemp"); // debug log
        }
      }
    });
  }

  void _fetchTemperaturePreferences() async {
    final tempRef = FirebaseDatabase.instance.ref().child(
      'Treshold/Temperature',
    );
    final isOnRef = FirebaseDatabase.instance.ref().child(
      'Notifications/Temperature',
    );

    final tempSnapshot = await tempRef.get();
    final isOnSnapshot = await isOnRef.get();

    if (mounted) {
      setState(() {
        if (tempSnapshot.exists) {
          final data = tempSnapshot.value as Map;
          minTemp = data['MIN'] ?? minTemp;
          maxTemp = data['MAX'] ?? maxTemp;
        }
        if (isOnSnapshot.exists) {
          isNotificationOn = isOnSnapshot.value == true;
        }
      });
    }
    print('Fetched user pref range: min:$minTemp and max:$maxTemp');
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
        title: const Text("Temperature"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
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
                      FirebaseDatabase.instance
                          .ref()
                          .child('Notifications/Temperature')
                          .set(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Temperature Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 70),
              decoration: BoxDecoration(
                color: getTemperatureColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "CURRENT TEMPERATURE: ${currentTemp != null ? currentTemp!.toStringAsFixed(2) : 'Loading...'}°C",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 5),

            // Temperature Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _temperatureSelector(minTemp, (value) {
                  setState(() {
                    minTemp = value;
                  });
                }),
                const SizedBox(width: 10),
                const Text(" - "),
                const SizedBox(width: 10),
                _temperatureSelector(maxTemp, (value) {
                  setState(() {
                    maxTemp = value;
                  });
                }),
                const SizedBox(width: 20),
                const Text(
                  "°C",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: () {
                    final tempPrefRef = FirebaseDatabase.instance.ref().child(
                      'Treshold/Temperature',
                    );
                    tempPrefRef.update({'MIN': minTemp, 'MAX': maxTemp});

                    FirebaseDatabase.instance.ref().child('Notification/isOn');

                    print("Preferences saved: Min $minTemp°C, Max $maxTemp°C");
                  },
                  child: const Text("SET"),
                ),
              ],
            ),

            const SizedBox(height: 5),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                const int defaultMinTemp = 26;
                const int defaultMaxTemp = 28;

                final tempPrefRef = FirebaseDatabase.instance.ref().child(
                  'Treshold/Temperature',
                );

                tempPrefRef.update({
                  'MIN': defaultMinTemp,
                  'MAX': defaultMaxTemp,
                });

                print(
                  "Default temperature set: Min $defaultMinTemp°C, Max $defaultMaxTemp°C",
                );
              },
              child: const Text("SET TO DEFAULT TEMPERATURE"),
            ),

            const Spacer(),

            const Text(
              "Note: Default aquarium temperature for fishes are 26-28°C.",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _temperatureSelector(int value, Function(int) onChanged) {
    final controller = TextEditingController(text: value.toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            onChanged(value + 1);
          },
          icon: const Icon(Icons.arrow_drop_up, size: 40),
        ),
        SizedBox(
          width: 70,
          height: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              final parsed = int.tryParse(text);
              if (parsed != null) {
                onChanged(parsed);
              }
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (value > 0) {
              onChanged(value - 1);
            }
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
