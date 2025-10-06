import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/autofeed/view/autofeed_camera_page.dart';
import 'package:aquacare_v5/features/scheduled_autofeed/view/scheduled_autofeed_page.dart';
import 'package:aquacare_v5/features/sensors/temperature/view/temperature_page.dart'
    as mvvm_temp;
import 'package:aquacare_v5/features/sensors/ph/view/ph_page.dart' as mvvm_ph;
import 'package:aquacare_v5/features/sensors/turbidity/view/turbidity_page.dart'
    as mvvm_turbidity;
import '../viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart' as core;
import 'package:aquacare_v5/core/models/threshold_model.dart' as aq;
import 'package:aquacare_v5/core/services/health_calculator.dart';
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

    // Check if thresholds are zero and set defaults
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (threshold.tempMin == 0 && threshold.tempMax == 0) {
        _setDefaultThresholds();
      }
    });

    // Use proper health calculation from reference
    final double health = HealthCalculator.calculateAquariumHealth(
      temperature: sensor.temperature,
      ph: sensor.ph,
      turbidity: sensor.turbidity,
      tempMin: threshold.tempMin,
      tempMax: threshold.tempMax,
      phMin: threshold.phMin,
      phMax: threshold.phMax,
      turbidityMin: threshold.turbidityMin,
      turbidityMax: threshold.turbidityMax,
    );

    // Calculate individual health percentages for display
    final double tempHealth = _calculateHealthPercentage(
      value: sensor.temperature,
      min: threshold.tempMin,
      max: threshold.tempMax,
    );
    final double turbidityHealth = _calculateHealthPercentage(
      value: sensor.turbidity,
      min: threshold.turbidityMin,
      max: threshold.turbidityMax,
    );
    final double phHealth = _calculateHealthPercentage(
      value: sensor.ph,
      min: threshold.phMin,
      max: threshold.phMax,
    );

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE
            Expanded(
              flex: 1,
              child: _buildLeftColumn(sensor, threshold, tempHealth, health),
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
    final bool tempInRange = HealthCalculator.isParameterInRange(
      sensor.temperature,
      threshold.tempMin,
      threshold.tempMax,
    );
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
        _healthBar(wqi: health),
      ],
    );
  }

  Widget _buildRightColumn(
    core.Sensor sensor,
    aq.Threshold threshold,
    double turbidityHealth,
    double phHealth,
  ) {
    final bool turbidityInRange = HealthCalculator.isParameterInRange(
      sensor.turbidity,
      threshold.turbidityMin,
      threshold.turbidityMax,
    );
    final bool phInRange = HealthCalculator.isParameterInRange(
      sensor.ph,
      threshold.phMin,
      threshold.phMax,
    );
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
        _scheduledAutofeedCard(),
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

  Widget _healthBar({required double wqi}) {
    // WQI ranges: 0-25 (Poor), 26-50 (Fair), 51-75 (Good), 76-100 (Excellent)
    final bool isGood = wqi >= 51.0;
    final Color barColor = isGood ? Colors.green : Colors.red;
    final String status =
        wqi >= 76
            ? 'Excellent'
            : wqi >= 51
            ? 'Good'
            : wqi >= 26
            ? 'Fair'
            : 'Poor';

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
              value: wqi / 100.0,
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
              "${wqi.toStringAsFixed(0)}%",
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
                status,
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

  // --- Helper function to calculate health percentage for display
  double _calculateHealthPercentage({
    required double value,
    required double min,
    required double max,
  }) {
    if (value <= min) return 0.0;
    if (value >= max) return 1.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  Widget _scheduledAutofeedCard() {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ScheduledAutofeedPage(
                    aquariumId: widget.aquariumId,
                    aquariumName: widget.aquariumName,
                  ),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 32, color: Colors.blue[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheduled Autofeeding',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage feeding schedules',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[600]),
          ],
        ),
      ),
    );
  }

  void _setDefaultThresholds() {
    // Set default thresholds for new aquariums
    final defaultThreshold = aq.Threshold(
      tempMin: 22.0,
      tempMax: 28.0,
      phMin: 6.5,
      phMax: 7.5,
      turbidityMin: 3.0,
      turbidityMax: 52.0,
    );
    ref
        .read(aquariumRepositoryProvider)
        .setThresholds(widget.aquariumId, defaultThreshold);
  }
}
