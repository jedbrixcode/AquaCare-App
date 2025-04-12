import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref("Sensors");

  double temperature = 0;
  double turbidity = 0;
  double ph = 0;

  bool autoFeed = false;
  bool autoLight = true;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  void _loadSensorData() {
    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value as Map;
      setState(() {
        temperature = data['Temperature'] * 1.0;
        turbidity = data['Turbidity'] * 1.0;
        ph = data['PH'] * 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tempPercent = ((temperature - 20) / 15).clamp(0.0, 1.0);
    final double turbidityPercent = (turbidity / 100).clamp(0.0, 1.0);
    final double phPercent = ((ph - 5) / 3).clamp(0.0, 1.0);

    // Determine health
    int score = 0;
    if (tempPercent >= 0.6 && tempPercent <= 0.8) score++;
    if (turbidityPercent <= 0.4) score++;
    if (phPercent >= 0.5 && phPercent <= 0.7) score++;
    double health = score / 3.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AquaCare Dashboard"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 8, 165, 146),
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/temperature'),
                    child: _bigCircleCard(
                      label: "Temperature",
                      value: "${temperature.toStringAsFixed(1)}°C",
                      percent: tempPercent,
                      icon: FontAwesomeIcons.temperatureHigh,
                      color: Colors.white,
                      height: 320,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/food'),
                    child: _switchCard(
                      label: "Auto Feed",
                      isOn: autoFeed,
                      color: Colors.green,
                      onChanged: (value) {
                        setState(() => autoFeed = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _healthBar(percent: health),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // RIGHT SIDE
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.pushNamed(context, '/waterturbidity'),
                    child: _horizontalBarCard(
                      label: "Turbidity",
                      percent: turbidityPercent,
                      isOn: true,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/phlevel'),
                    child: _circleCard(
                      label: "pH level",
                      value: ph.toStringAsFixed(1),
                      percent: phPercent,
                      icon: FontAwesomeIcons.vialCircleCheck,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/light'),
                    child: _switchCard(
                      label: "Auto light",
                      isOn: autoLight,
                      color: Colors.green,
                      onChanged: (value) {
                        setState(() => autoLight = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigCircleCard({
    required String label,
    required String value,
    required double percent,
    required IconData icon,
    required Color color,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label at the top
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Circle Indicator with icon inside
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 16,
            percent: percent.clamp(0.0, 1.0),
            center: Icon(icon, color: color, size: 48),
            progressColor: Colors.white,
            backgroundColor: Colors.black,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),

          // Temperature value as big number
          Text(
            value,
            style: const TextStyle(
              fontSize: 46, // 👈 Bigger font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleCard({
    required String label,
    required String value,
    required double percent,
    required IconData icon,
    required Color color,
    double height = 320,
    double width = double.infinity,
  }) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label at the top
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Circle Indicator with icon inside
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 16,
            percent: percent.clamp(0.0, 1.0),
            center: Icon(icon, color: color, size: 48), // Larger icon size
            progressColor: Colors.white,
            backgroundColor: Colors.black,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),

          // Value as a large number
          Text(
            value,
            style: const TextStyle(
              fontSize: 52, // Bigger number
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalBarCard({
    required String label,
    required double percent,
    required bool isOn,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Using Stack to position the value over the progress bar
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: percent,
                  color: color,
                  backgroundColor: Colors.white,
                  minHeight: 20,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${(percent * 100).toStringAsFixed(0)} NTU",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color, // Make the text blend with the bar
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchCard({
    required String label,
    required bool isOn,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: isOn ? color : Colors.grey[600],
              ),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onChanged(!isOn),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthBar({required double percent}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aquarium Health",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        // 🔽 Adjust width here
        SizedBox(
          width: 230, // 👈 reduce this value as needed
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 18,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          "${(percent * 100).toStringAsFixed(0)}%",
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }
}
