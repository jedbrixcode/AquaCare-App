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
    _loadThresholdData();
  }

  // Thresholds
  double tempMin = 22;
  double tempMax = 28;
  double turbidityMin = 3;
  double turbidityMax = 52;
  double phMin = 6.5;
  double phMax = 7.5;

  void _loadSensorData() {
    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value as Map;
      setState(() {
        temperature = (data['Temperature'] ?? 0) * 1.0;
        turbidity = (data['Turbidity'] ?? 0) * 1.0;
        ph = (data['PH'] ?? 0) * 1.0;
      });
    });
  }

  void _loadThresholdData() {
    FirebaseDatabase.instance.ref('Treshold').once().then((event) {
      final data = event.snapshot.value as Map;
      setState(() {
        tempMin = (data['Temperature']['MIN'] ?? 22).toDouble();
        tempMax = (data['Temperature']['MAX'] ?? 28).toDouble();
        turbidityMin = (data['Turbidity']['MIN'] ?? 3).toDouble();
        turbidityMax = (data['Turbidity']['MAX'] ?? 52).toDouble();
        phMin = (data['PH']['MIN'] ?? 6.5).toDouble();
        phMax = (data['PH']['MAX'] ?? 7.5).toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tempHealth = _calculateHealth(
      value: temperature,
      min: tempMin,
      max: tempMax,
    );
    final double turbidityHealth = _calculateHealth(
      value: turbidity,
      min: turbidityMin,
      max: turbidityMax,
    );
    final double phHealth = _calculateHealth(value: ph, min: phMin, max: phMax);

    // Assign Weights: Temperature > pH > Turbidity
    const double tempWeight = 0.5;
    const double phWeight = 0.3;
    const double turbidityWeight = 0.2;

    double health =
        (tempHealth * tempWeight) +
        (phHealth * phWeight) +
        (turbidityHealth * turbidityWeight);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AquaCare Dashboard"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(
          255,
          107,
          159,
          255,
        ), // Set the background color here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                'AquaCare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),
            ListTile(
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/homepage');
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Chat with AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Monitoring Graphs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/graphs');
              },
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
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
                      value: "${temperature.toStringAsFixed(0)}°C",
                      percent: tempHealth,
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
                      percent: turbidityHealth,
                      isOn: true,
                      color: Colors.green,
                      rawValue: turbidity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/phlevel'),
                    child: _circleCard(
                      label: "pH level",
                      value: ph.toStringAsFixed(1),
                      percent: phHealth,
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
              fontSize: 46,
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
            center: Icon(icon, color: color, size: 48),
            progressColor: Colors.white,
            backgroundColor: Colors.black,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 52,
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
    required double rawValue,
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
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    "${rawValue.toStringAsFixed(0)} NTU",
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
        SizedBox(
          width: 230,
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

  // --- Helper function to calculate health based on thresholds
  double _calculateHealth({
    required double value,
    required double min,
    required double max,
  }) {
    if (value <= min) return 0.0;
    if (value >= max) return 1.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }
}
