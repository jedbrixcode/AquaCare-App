import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aquacare_v5/pages/Services/chart_service.dart';

class SensorGraphsPage extends StatefulWidget {
  const SensorGraphsPage({super.key});

  @override
  State<SensorGraphsPage> createState() => _SensorGraphsPageState();
}

class _SensorGraphsPageState extends State<SensorGraphsPage> {
  bool showDaily = true;

  Future<void> _reload() async {
    setState(() {});
  }

  Widget _buildChart(
    List<SensorDataPoint> dataPoints,
    String label,
    Color color,
  ) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(child: Text("No $label log data found for chart.")),
      );
    }

    double minY =
        dataPoints.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 1;
    double maxY =
        dataPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1;
    double yInterval = ((maxY - minY) / 3).ceil().toDouble().clamp(
      1,
      double.infinity,
    );

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: true),
          minX: 0,
          maxX: dataPoints.length.toDouble() - 1,
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Time',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval:
                    (dataPoints.length <= 6)
                        ? 1
                        : (dataPoints.length / 3).floorToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dataPoints.length) {
                    return Container();
                  }
                  final timeLabel = dataPoints[index].formattedTime;
                  return SideTitleWidget(
                    meta: meta,
                    space: 1,
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots:
                  dataPoints
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                      .toList(),
              isCurved: true,
              barWidth: 4,
              color: color,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCharts() {
    return Column(
      children: [
        const SizedBox(height: 16),
        FutureBuilder<List<SensorDataPoint>>(
          future: ChartServices.fetchSensorData('Temperature'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No temperature log data found.");
            }
            return _buildChart(
              snapshot.data!,
              'Temperature',
              Colors.blueAccent,
            );
          },
        ),
        const SizedBox(height: 32),
        FutureBuilder<List<SensorDataPoint>>(
          future: ChartServices.fetchSensorData('Turbidity'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No turbidity log data found.");
            }
            return _buildChart(snapshot.data!, 'Turbidity', Colors.green);
          },
        ),
        const SizedBox(height: 32),
        FutureBuilder<List<SensorDataPoint>>(
          future: ChartServices.fetchSensorData('PH'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No pH log data found.");
            }
            return _buildChart(
              snapshot.data!,
              'pH',
              const Color.fromARGB(255, 220, 55, 249),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyCharts() {
    return FutureBuilder<List<SensorDataPoint>>(
      future: ChartServices.fetchAverageData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No weekly average data found."));
        }

        final temperatureData =
            snapshot.data!.where((e) => e.label == 'Temperature').toList();
        final turbidityData =
            snapshot.data!.where((e) => e.label == 'Turbidity').toList();
        final phData = snapshot.data!.where((e) => e.label == 'PH').toList();

        return Column(
          children: [
            _buildChart(
              temperatureData,
              'Temperature (Avg)',
              Colors.blueAccent,
            ),
            const SizedBox(height: 32),
            _buildChart(turbidityData, 'Turbidity (Avg)', Colors.green),
            const SizedBox(height: 32),
            _buildChart(phData, 'pH (Avg)', Colors.purple),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Graphs'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Daily'),
              Switch(
                value: !showDaily,
                onChanged: (value) {
                  setState(() {
                    showDaily = !value;
                  });
                },
              ),
              const Text('Weekly'),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: showDaily ? _buildDailyCharts() : _buildWeeklyCharts(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
