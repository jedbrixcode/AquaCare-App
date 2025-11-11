import 'package:aquacare_v5/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/sensor_graphs_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class SensorGraphsPage extends ConsumerWidget {
  const SensorGraphsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(sensorGraphsViewModelProvider);
    final aquariumNames = viewModel.aquariumNames;

    // Use names directly from state when needed
    final nameToId = ref.watch(sensorGraphsViewModelProvider.notifier).nameToId;

    // Removed unused validValue
    final graphs = ref.watch(sensorGraphsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeekly = graphs.range == GraphRange.weekly;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monitoring Graphs',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: ListTileThemeData(
              textColor: isDark ? Colors.white : Colors.black,
              iconColor: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Aquarium:'),
                  const SizedBox(width: 7),

                  // 🔹 Dropdown (shortened)
                  Flexible(
                    flex: 1,
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: aquariumNames.valueOrNull?.firstWhere(
                        (n) => nameToId[n] == viewModel.aquariumId,
                        orElse: () => aquariumNames.valueOrNull?.first ?? '',
                      ),
                      onChanged: (v) {
                        if (v?.isNotEmpty ?? false) {
                          ref
                              .read(sensorGraphsViewModelProvider.notifier)
                              .setAquariumByName(v!);
                        }
                      },
                      items: aquariumNames.when(
                        data:
                            (names) =>
                                names
                                    .map(
                                      (n) => DropdownMenuItem(
                                        value: n,
                                        child: Text(n),
                                      ),
                                    )
                                    .toList(),
                        loading:
                            () => const [
                              DropdownMenuItem(
                                value: '',
                                child: Text('Loading...'),
                              ),
                            ],
                        error:
                            (_, __) => const [
                              DropdownMenuItem(value: '', child: Text('Error')),
                            ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: ResponsiveHelper.horizontalPadding(context) / 1.5,
                  ),

                  // 🔹 Segmented Button (cleaned + compact)
                  Flexible(
                    child: SegmentedButton<GraphRange>(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          final theme = Theme.of(context);
                          return states.contains(WidgetState.selected)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface.withOpacity(0.2);
                        }),
                        foregroundColor: WidgetStateProperty.all(
                          isDark ? Colors.white : Colors.black87,
                        ),
                        side: WidgetStateProperty.resolveWith((states) {
                          final theme = Theme.of(context);
                          final color = theme.colorScheme.primary;
                          return BorderSide(
                            color:
                                states.contains(WidgetState.selected)
                                    ? color
                                    : theme.colorScheme.onSurface.withOpacity(
                                      0.3,
                                    ),
                            width:
                                states.contains(WidgetState.selected) ? 1.5 : 1,
                          );
                        }),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 0,
                          ),
                        ),
                      ),
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
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.verticalPadding(context) / 12),

              // Scrollable chart area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: ResponsiveHelper.verticalPadding(context),
                      ),
                      if (graphs.range == GraphRange.hourly) ...[
                        graphs.temperature.when(
                          data:
                              (d) => _buildChart(
                                d,
                                'Temperature',
                                Colors.blueAccent,
                                context,
                                isWeekly,
                                isDark,
                              ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                        ),
                        SizedBox(
                          height:
                              ResponsiveHelper.verticalPadding(context) + 12.0,
                        ),
                        graphs.turbidity.when(
                          data:
                              (d) => _buildChart(
                                d,
                                'Turbidity',
                                Colors.green,
                                context,
                                isWeekly,
                                isDark,
                              ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                        ),
                        SizedBox(
                          height:
                              ResponsiveHelper.verticalPadding(context) + 12.0,
                        ),
                        graphs.ph.when(
                          data:
                              (d) => _buildChart(
                                d,
                                'pH',
                                const Color.fromARGB(255, 220, 55, 249),
                                context,
                                isWeekly,
                                isDark,
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
                                  context,
                                  isWeekly,
                                  isDark,
                                ),
                                SizedBox(
                                  height:
                                      ResponsiveHelper.verticalPadding(
                                        context,
                                      ) +
                                      12.0,
                                ),
                                _buildChart(
                                  turb,
                                  'Turbidity (Avg)',
                                  Colors.green,
                                  context,
                                  isWeekly,
                                  isDark,
                                ),
                                SizedBox(
                                  height:
                                      ResponsiveHelper.verticalPadding(
                                        context,
                                      ) +
                                      12.0,
                                ),
                                _buildChart(
                                  ph,
                                  'pH (Avg)',
                                  Colors.purple,
                                  context,
                                  isWeekly,
                                  isDark,
                                ),
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
      ),
    );
  }

  Widget _buildChart(
    List<dynamic> dataPoints,
    String label,
    Color color,
    BuildContext context,
    bool isWeekly,
    bool isDark,
  ) {
    final baseLine = LineChartBarData(
      spots: List.generate(isWeekly ? 7 : 25, (i) => FlSpot(i.toDouble(), 0)),
      isCurved: false,
      color: Colors.grey.withOpacity(0.2),
      barWidth: 1,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );

    // ✅ Map actual data (use hour as x if available)
    final spots =
        dataPoints.asMap().entries.map((entry) {
          final point = entry.value as dynamic;
          final val = point.value as double;
          final x =
              isWeekly ? entry.key.toDouble() : point.time.hour.toDouble();
          return FlSpot(x, val);
        }).toList();

    double minY = 0;
    double maxY = 14;
    double yInterval = 2;

    if (spots.isNotEmpty) {
      minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1;
      maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1;
      yInterval = (((maxY - minY) / 3).ceil()).toDouble().clamp(
        1.0,
        double.infinity,
      );
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => darkTheme.colorScheme.secondary,
            ),
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.white, strokeWidth: 1),
                  FlDotData(show: true),
                );
              }).toList();
            },
          ),
          minX: 0,
          maxX: isWeekly ? 6 : 24,
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
              axisNameWidget: Text(
                isWeekly ? 'Days' : 'Time',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: isWeekly ? 1 : 4,
                getTitlesWidget: (value, meta) {
                  if (isWeekly) {
                    // Show Monday–Sunday labels only
                    final days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];
                    int index = value.toInt();
                    if (index < 0 || index >= days.length) {
                      return const SizedBox();
                    }
                    return Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                  } else {
                    if (value % 4 != 0 && value != 24) return const SizedBox();
                    final hour = value.toInt().clamp(0, 24);
                    final label =
                        hour == 24
                            ? '24:00'
                            : '${hour.toString().padLeft(2, '0')}:00';

                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Padding(
                        padding: EdgeInsets.only(left: hour == 0 ? 20 : 0),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
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
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            baseLine,
            if (spots.isNotEmpty)
              LineChartBarData(
                spots: spots,
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
