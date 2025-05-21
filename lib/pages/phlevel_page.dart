import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:aquacare_v5/pages/Services/notif_service.dart';

class PhlevelPage extends StatefulWidget {
  const PhlevelPage({super.key});

  @override
  State<PhlevelPage> createState() => _PHPageState();
}

// class to fetch ph level from firebase
class _PHPageState extends State<PhlevelPage> {
  bool isNotificationOn = false;
  double minPH = 6.5;
  double maxPH = 7.5;
  double? currentPH;

  final NotificationService _notificationService = NotificationService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _fetchPH();
    _fetchPHPreferences();
  }

  void _fetchPH() {
    _database.child("Sensors/PH").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double? newPH = double.tryParse(data.toString());
        if (newPH != null && mounted) {
          setState(() {
            currentPH = newPH;
          });
          print("Fetched PH: $currentPH");
        }
      }
    });
  }

  void _fetchPHPreferences() async {
    final minMaxRef = _database.child('Treshold/PH');
    final notifRef = _database.child('Notifications/PH');

    final minMaxSnap = await minMaxRef.get();
    final notifSnap = await notifRef.get();

    if (mounted) {
      setState(() {
        if (minMaxSnap.exists) {
          final data = Map<String, dynamic>.from(minMaxSnap.value as Map);
          minPH = (data['MIN'] ?? minPH).toDouble();
          maxPH = (data['MAX'] ?? maxPH).toDouble();
        }
        if (notifSnap.exists) {
          isNotificationOn = notifSnap.value == true;
        }
      });
    }

    print('PH Range from Firebase: Min: $minPH, Max: $maxPH');
  }

  Color getPHColor() {
    if (currentPH == null) return Colors.grey;
    if (currentPH! > maxPH) return Colors.red;
    if (currentPH! < minPH) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PH Level'),
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
                    value: isNotificationOn,
                    onChanged: (value) {
                      setState(() {
                        isNotificationOn = value;
                      });
                      _database.child('Notifications/PH').set(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PH Display
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 110,
              ),
              decoration: BoxDecoration(
                color: getPHColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "CURRENT PH: ${currentPH?.toStringAsFixed(2) ?? 'Loading...'}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 5),

            // Min-Max Set Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _phSelector(minPH, (val) => setState(() => minPH = val)),
                const SizedBox(width: 10),
                const Text(" - "),
                const SizedBox(width: 10),
                _phSelector(maxPH, (val) => setState(() => maxPH = val)),
                const SizedBox(width: 10),
                const Text("pH"),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _database.child("Treshold/PH").update({
                      "MIN": double.parse(minPH.toStringAsFixed(1)),
                      "MAX": double.parse(maxPH.toStringAsFixed(1)),
                    });
                    print("Saved PH preferences: Min $minPH, Max $maxPH");
                  },
                  child: const Text("SET"),
                ),
              ],
            ),

            const SizedBox(height: 5),

            ElevatedButton(
              onPressed: () {
                const defaultMin = 6.5;
                const defaultMax = 7.5;
                _database.child("Treshold/PH").update({
                  "MIN": double.parse(defaultMin.toStringAsFixed(1)),
                  "MAX": double.parse(defaultMax.toStringAsFixed(1)),
                });
                setState(() {
                  minPH = defaultMin;
                  maxPH = defaultMax;
                });
                print("PH reset to default range.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("SET TO DEFAULT PH"),
            ),

            const Spacer(),

            const Text(
              "Note: Ideal PH range for aquariums is 6.5 to 7.5",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _phSelector(double value, Function(double) onChanged) {
    final controller = TextEditingController(text: value.toStringAsFixed(1));

    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up, size: 30),
          onPressed: () => onChanged((value + 0.1).clamp(0.0, 14.0)),
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
              if (val != null) onChanged(val.clamp(0.0, 14.0));
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 5),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down, size: 30),
          onPressed: () => onChanged((value - 0.1).clamp(0.0, 14.0)),
        ),
      ],
    );
  }
}
