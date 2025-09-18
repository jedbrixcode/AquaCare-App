import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/autofeed/view/camera_page.dart';
import 'package:aquacare_v5/features/sensors/temperature/view/temperature_page.dart'
    as mvvm_temp;
import 'package:aquacare_v5/features/sensors/ph/view/ph_page.dart' as mvvm_ph;
import 'package:aquacare_v5/features/sensors/turbidity/view/turbidity_page.dart'
    as mvvm_turbidity;
import '../viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart' as core;
import 'package:aquacare_v5/core/models/threshold_model.dart' as aq;
import 'package:aquacare_v5/utils/responsive_helper.dart';

class AquariumDetailPage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const AquariumDetailPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<AquariumDetailPage> createState() => _AquariumDetailPageState();
}

class _AquariumDetailPageState extends ConsumerState<AquariumDetailPage> {
  @override
  Widget build(BuildContext context) {
    final sensorAsync = ref.watch(aquariumSensorProvider(widget.aquariumId));
    final thresholdAsync = ref.watch(
      aquariumThresholdProvider(widget.aquariumId),
    );
    final autoLightAsync = ref.watch(
      aquariumAutoLightProvider(widget.aquariumId),
    );

    final sensor =
        sensorAsync.asData?.value ??
        const core.Sensor(temperature: 0, turbidity: 0, ph: 0);
    final threshold =
        thresholdAsync.asData?.value ??
        const aq.Threshold(
          tempMin: 22,
          tempMax: 28,
          turbidityMin: 3,
          turbidityMax: 52,
          phMin: 6.5,
          phMax: 7.5,
        );
    final autoLight = autoLightAsync.asData?.value ?? true;

    final double tempHealth = _calculateHealth(
      value: sensor.temperature,
      min: threshold.tempMin,
      max: threshold.tempMax,
    );
    final double turbidityHealth = _calculateHealth(
      value: sensor.turbidity,
      min: threshold.turbidityMin,
      max: threshold.turbidityMax,
    );
    final double phHealth = _calculateHealth(
      value: sensor.ph,
      min: threshold.phMin,
      max: threshold.phMax,
    );

    // Assign Weights: Temperature > pH > Turbidity
    const double tempWeight = 0.5;
    const double phWeight = 0.3;
    const double turbidityWeight = 0.2;

    double health =
        (tempHealth * tempWeight) +
        (phHealth * phWeight) +
        (turbidityHealth * turbidityWeight);

    // Intentionally not storing all-in-range flag; health is derived per-sensor and weighted

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
        padding: ResponsiveHelper.getScreenPadding(context),
        child:
            ResponsiveHelper.isMobile(context)
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftColumn(sensor, threshold, tempHealth, health),
                    const SizedBox(height: 20),
                    _buildRightColumn(
                      sensor,
                      threshold,
                      turbidityHealth,
                      phHealth,
                      autoLight,
                    ),
                  ],
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT SIDE
                    Expanded(
                      flex: 1,
                      child: _buildLeftColumn(
                        sensor,
                        threshold,
                        tempHealth,
                        health,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // RIGHT SIDE
                    Expanded(
                      flex: 1,
                      child: _buildRightColumn(
                        sensor,
                        threshold,
                        turbidityHealth,
                        phHealth,
                        autoLight,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildLeftColumn(
    core.Sensor sensor,
    aq.Threshold threshold,
    double tempHealth,
    double health,
  ) {
    final bool tempInRange =
        sensor.temperature >= threshold.tempMin &&
        sensor.temperature <= threshold.tempMax;
    final Color tempColor = tempInRange ? Colors.green : Colors.red;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
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
            value: "${sensor.temperature.toStringAsFixed(1)}°C",
            percent: tempHealth,
            icon: FontAwesomeIcons.temperatureHigh,
            ringColor: tempColor,
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
            context: context,
            label: "Auto Feeding",
            color: Colors.green,
            aquariumId: widget.aquariumId,
            aquariumName: widget.aquariumName,
          ),
        ),
        const SizedBox(height: 20),
        _healthBar(percent: health),
      ],
    );
  }

  Widget _buildRightColumn(
    core.Sensor sensor,
    aq.Threshold threshold,
    double turbidityHealth,
    double phHealth,
    bool autoLight,
  ) {
    final bool turbidityInRange =
        sensor.turbidity >= threshold.turbidityMin &&
        sensor.turbidity <= threshold.turbidityMax;
    final bool phInRange =
        sensor.ph >= threshold.phMin && sensor.ph <= threshold.phMax;
    final Color turbidityColor = turbidityInRange ? Colors.green : Colors.red;
    final Color phColor = phInRange ? Colors.green : Colors.red;

    return Column(
      children: [
        GestureDetector(
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => mvvm_turbidity.TurbidityPage(
                        aquariumId: widget.aquariumId,
                        aquariumName: widget.aquariumName,
                      ),
                ),
              ),
          child: _horizontalBarCard(
            label: "Turbidity",
            percent: turbidityHealth,
            isOn: true,
            color: turbidityColor,
            rawValue: sensor.turbidity,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => mvvm_ph.PhPage(
                        aquariumId: widget.aquariumId,
                        aquariumName: widget.aquariumName,
                      ),
                ),
              ),
          child: _circleCard(
            label: "pH level",
            value: sensor.ph.toStringAsFixed(2),
            percent: phHealth,
            icon: FontAwesomeIcons.vialCircleCheck,
            ringColor: phColor,
            color: Colors.white,
            height: 300,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/light'),
          child: _switchCard(
            label: "Auto light",
            isOn: autoLight,
            color: Colors.green,
            onChanged: (v) {
              ref
                  .read(aquariumRepositoryProvider)
                  .setAutoLightStatus(widget.aquariumId, v);
            },
          ),
        ),
      ],
    );
  }

  Widget _bigCircleCard({
    required String label,
    required String value,
    required double percent,
    required IconData icon,
    Color? ringColor,
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
            progressColor: ringColor ?? Colors.white,
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
    Color? ringColor,
    required Color color,
    required double height,
    required double width,
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
            progressColor: ringColor ?? Colors.white,
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
    final bool isGood = percent >= 1.0 - 1e-9; // all within thresholds => 1.0
    final Color barColor = isGood ? Colors.green : Colors.red;
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
              color: barColor,
            ),
          ),
        ),

        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                percent >= 1.0 ? 'Good' : 'Bad',
                style: TextStyle(color: barColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _autoFeedCard({
    required BuildContext context,
    required String label,
    required Color color,
    required String aquariumId,
    required String aquariumName,
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CameraPage(
                        aquariumId: aquariumId,
                        aquariumName: aquariumName,
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
