import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquacare_v5/features/autofeed/view/camera_page.dart';
import 'package:aquacare_v5/features/sensors/temperature/view/temperature_page.dart'
    as mvvm_temp;

class AquariumDetailPage extends StatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const AquariumDetailPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  State<AquariumDetailPage> createState() => _AquariumDetailPageState();
}

class _AquariumDetailPageState extends State<AquariumDetailPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  double temperature = 0;
  double turbidity = 0;
  double ph = 0;

  bool autoLight = true;

  // Thresholds
  double tempMin = 22;
  double tempMax = 28;
  double turbidityMin = 3;
  double turbidityMax = 52;
  double phMin = 6.5;
  double phMax = 7.5;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
    _loadThresholdData();
    _loadAutoFeedStatus();
  }

  void _loadSensorData() {
    _databaseRef
        .child('aquariums')
        .child(widget.aquariumId)
        .child('sensors')
        .onValue
        .listen((event) {
          if (event.snapshot.value != null) {
            final data = event.snapshot.value as Map;
            setState(() {
              temperature = (data['temperature'] ?? 0) * 1.0;
              turbidity = (data['turbidity'] ?? 0) * 1.0;
              ph = (data['ph'] ?? 0) * 1.0;
            });
          }
        });
  }

  void _loadThresholdData() {
    _databaseRef
        .child('aquariums')
        .child(widget.aquariumId)
        .child('threshold')
        .onValue
        .listen((event) {
          if (event.snapshot.value != null) {
            final data = event.snapshot.value as Map;
            setState(() {
              tempMin = (data['temperature']?['min'] ?? 22) * 1.0;
              tempMax = (data['temperature']?['max'] ?? 28) * 1.0;
              turbidityMin = (data['turbidity']?['min'] ?? 3) * 1.0;
              turbidityMax = (data['turbidity']?['max'] ?? 52) * 1.0;
              phMin = (data['ph']?['min'] ?? 6.5) * 1.0;
              phMax = (data['ph']?['max'] ?? 7.5) * 1.0;
            });
          }
        });
  }

  void _loadAutoFeedStatus() {
    _databaseRef
        .child('aquariums')
        .child(widget.aquariumId)
        .child('auto_feed')
        .onValue
        .listen((event) {
          if (mounted) {
            setState(() {
              autoLight = event.snapshot.value == true;
            });
          }
        });
  }

  void _updateAutoLight(bool value) {
    setState(() {
      autoLight = value;
    });
    _databaseRef
        .child('aquariums')
        .child(widget.aquariumId)
        .child('auto_light')
        .set(value);
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
        title: Text("${widget.aquariumName} Dashboard"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        toolbarHeight: 100,
        centerTitle: true,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => mvvm_temp.TemperaturePage(
                                aquariumId: widget.aquariumId,
                                aquariumName: widget.aquariumName,
                              ),
                        ),
                      );
                    },
                    child: _bigCircleCard(
                      label: "Temperature",
                      value: "${temperature.toStringAsFixed(0)}°C",
                      percent: tempHealth,
                      icon: FontAwesomeIcons.temperatureHigh,
                      color: Colors.white,
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CameraPage(
                                aquariumId: widget.aquariumId,
                                aquariumName: widget.aquariumName,
                              ),
                        ),
                      );
                    },
                    child: _autoFeedCard(
                      label: "Auto Feeding",
                      color: Colors.green,
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
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/light'),
                    child: _switchCard(
                      label: "Auto light",
                      isOn: autoLight,
                      color: Colors.green,
                      onChanged: _updateAutoLight,
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
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
              fontSize: 36,
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
    double height = 350,
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
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
                      color: Colors.white,
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

  Widget _autoFeedCard({required String label, required Color color}) {
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CameraPage(
                        aquariumId: widget.aquariumId,
                        aquariumName: widget.aquariumName,
                      ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: color,
              ),
              alignment: Alignment.center,
              child: const Text(
                "Configure",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
