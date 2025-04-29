import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/pages/Services/notif_service.dart';

class WaterTurbidityPage extends StatefulWidget {
  const WaterTurbidityPage({super.key});

  @override
  State<WaterTurbidityPage> createState() => _WaterTurbidityPageState();
}

class _WaterTurbidityPageState extends State<WaterTurbidityPage> {
  final NotificationService _notificationService = NotificationService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool isTurbidityNotifOn = false;
  double minTurbidity = 0;
  double maxTurbidity = 100;
  double? currentTurbidity;

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _fetchTurbidity();
    _fetchTurbidityPreferences();
  }

  void _fetchTurbidity() {
    _database.child("Sensors/Turbidity").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double? newTurbidity = double.tryParse(data.toString());
        if (newTurbidity != null && mounted) {
          setState(() {
            currentTurbidity = newTurbidity;
          });
          print("Fetched Turbidity: $currentTurbidity");
        }
      }
    });
  }

  void _fetchTurbidityPreferences() async {
    final minMaxRef = _database.child('Treshold/Turbidity');
    final notifRef = _database.child('Notifications/Turbidity');

    final minMaxSnap = await minMaxRef.get();
    final notifSnap = await notifRef.get();

    if (mounted) {
      setState(() {
        if (minMaxSnap.exists) {
          final data = Map<String, dynamic>.from(minMaxSnap.value as Map);
          minTurbidity = (data['MIN'] ?? minTurbidity).toDouble();
          maxTurbidity = (data['MAX'] ?? maxTurbidity).toDouble();
        }
        if (notifSnap.exists) {
          isTurbidityNotifOn = notifSnap.value == true;
        }
      });
    }

    print(
      'Turbidity Range from Firebase: Min: $minTurbidity, Max: $maxTurbidity',
    );
  }

  Color getTurbidityColor(double? turbidityValue) {
    switch (turbidityValue) {
      case null:
        return Colors.grey;
      case < 5:
        return Colors.green;
      case < 20:
        return Colors.lightGreen;
      case < 40:
        return Colors.yellow;
      case < 70:
        return Colors.orange;
      case < 101:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  String getTurbidityDescription(double? turbidityValue) {
    switch (turbidityValue) {
      case null:
        return "Loading...";
      case < 5:
        return "Crystal Clear";
      case < 20:
        return "Slightly Cloudy";
      case < 40:
        return "Cloudy";
      case < 70:
        return "Murky";
      case < 101:
        return "Very Murky";
      default:
        return "Very Murky"; // Or "Extremely Turbid"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Turbidity"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Notification toggle
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
                    value: isTurbidityNotifOn,
                    onChanged: (value) {
                      setState(() {
                        isTurbidityNotifOn = value;
                      });
                      _database.child('Notifications/Turbidity').set(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Turbidity Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 70),
              decoration: BoxDecoration(
                color: getTurbidityColor(currentTurbidity),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "CURRENT TURBIDITY: ${currentTurbidity?.toStringAsFixed(0) ?? 'Loading...'} NTU",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8), // Add some spacing
                  Text(
                    getTurbidityDescription(
                      currentTurbidity,
                    ), // Get the description
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Min-Max Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _turbiditySelector(
                  minTurbidity,
                  (val) => setState(() => minTurbidity = val),
                ),
                const SizedBox(width: 10),
                const Text(" - "),
                const SizedBox(width: 10),
                _turbiditySelector(
                  maxTurbidity,
                  (val) => setState(() => maxTurbidity = val),
                ),
                const SizedBox(width: 10),
                const Text("NTU"),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _database.child("Treshold/Turbidity").update({
                      "MIN": minTurbidity,
                      "MAX": maxTurbidity,
                    });
                    print(
                      "Saved Turbidity preferences: Min $minTurbidity, Max $maxTurbidity",
                    );
                  },
                  child: const Text("SET"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Reset button
            ElevatedButton(
              onPressed: () {
                const defaultMin = 0.0;
                const defaultMax = 50.0;
                _database.child("Treshold/Turbidity").update({
                  "MIN": defaultMin,
                  "MAX": defaultMax,
                });
                setState(() {
                  minTurbidity = defaultMin;
                  maxTurbidity = defaultMax;
                });
                print("Turbidity reset to default range.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("SET TO DEFAULT TURBIDITY"),
            ),

            const Spacer(),

            const Text(
              "Note: Acceptable turbidity for aquariums is typically under 50 NTU.",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _turbiditySelector(double value, Function(double) onChanged) {
    final controller = TextEditingController(text: value.toStringAsFixed(2));

    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up, size: 30),
          onPressed: () => onChanged((value + 1).clamp(0.0, 1000.0)),
        ),
        SizedBox(
          width: 70,
          height: 50,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              final val = double.tryParse(text);
              if (val != null) onChanged(val.clamp(0.0, 1000.0));
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 5),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down, size: 30),
          onPressed: () => onChanged((value - 1).clamp(0.0, 1000.0)),
        ),
      ],
    );
  }
}
