import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/sensor_graphs_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorGraphsPage extends ConsumerWidget {
  const SensorGraphsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphs = ref.watch(sensorGraphsViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Graphs'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Aquarium:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: graphs.aquariumId,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('1')),
                    DropdownMenuItem(value: '2', child: Text('2')),
                    DropdownMenuItem(value: '3', child: Text('3')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    ref
                        .read(sensorGraphsViewModelProvider.notifier)
                        .setAquarium(v);
                  },
                ),
                const Spacer(),
                SegmentedButton<GraphRange>(
                  segments: const [
                    ButtonSegment(
                      value: GraphRange.hourly,
                      label: Text('Hourly'),
                    ),
                    ButtonSegment(
                      value: GraphRange.weekly,
                      label: Text('Weekly'),
                    ),
                  ],
                  selected: {graphs.range},
                  onSelectionChanged: (s) {
                    if (s.isNotEmpty) {
                      ref
                          .read(sensorGraphsViewModelProvider.notifier)
                          .setRange(s.first);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (graphs.range == GraphRange.hourly) ...[
                      graphs.temperature.when(
                        data:
                            (d) => _buildChart(
                              d,
                              'Temperature',
                              Colors.blueAccent,
                            ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 24),
                      graphs.turbidity.when(
                        data: (d) => _buildChart(d, 'Turbidity', Colors.green),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 24),
                      graphs.ph.when(
                        data:
                            (d) => _buildChart(
                              d,
                              'pH',
                              const Color.fromARGB(255, 220, 55, 249),
                            ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ] else ...[
                      graphs.weekly.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (data) {
                          final temp =
                              data
                                  .where((e) => e.label == 'Temperature')
                                  .toList();
                          final turb =
                              data
                                  .where((e) => e.label == 'Turbidity')
                                  .toList();
                          final ph =
                              data.where((e) => e.label == 'PH').toList();
                          return Column(
                            children: [
                              _buildChart(
                                temp,
                                'Temperature (Avg)',
                                Colors.blueAccent,
                              ),
                              const SizedBox(height: 24),
                              _buildChart(
                                turb,
                                'Turbidity (Avg)',
                                Colors.green,
                              ),
                              const SizedBox(height: 24),
                              _buildChart(ph, 'pH (Avg)', Colors.purple),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<dynamic> dataPoints, String label, Color color) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(child: Text('No $label data found.')),
      );
    }

    final double minY =
        dataPoints
            .map((e) => e.value as double)
            .reduce((a, b) => a < b ? a : b) -
        1.0;
    final double maxY =
        dataPoints
            .map((e) => e.value as double)
            .reduce((a, b) => a > b ? a : b) +
        1.0;
    final double yInterval = (((maxY - minY) / 3).ceil()).toDouble().clamp(
      1.0,
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
                  if (index < 0 || index >= dataPoints.length)
                    return const SizedBox();
                  final timeLabel = dataPoints[index].formattedTime as String;
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
                      .map(
                        (e) =>
                            FlSpot(e.key.toDouble(), (e.value.value as double)),
                      )
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
}
