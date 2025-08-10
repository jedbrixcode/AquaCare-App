import 'package:aquacare_v5/features/aquarium/repository/aquarium_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:aquacare_v5/features/aquarium/view/aquarium_detail_page.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class AquariumDashboardPage extends ConsumerWidget {
  const AquariumDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(aquariumsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaCare Dashboard'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: summaryAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Aquariums Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Waiting for aquarium data...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Aquariums (${summaries.length})',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(aquariumsSummaryProvider);
                    },
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: summaries.length,
                      itemBuilder: (context, index) {
                        final s = summaries[index];
                        return _buildAquariumCard(context, s);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading aquariums',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(aquariumsSummaryProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildAquariumCard(BuildContext context, AquariumSummary s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => AquariumDetailPage(
                      aquariumId: s.aquariumId,
                      aquariumName:
                          s.name.isNotEmpty
                              ? s.name
                              : 'Aquarium ${s.aquariumId}',
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.name.isNotEmpty ? s.name : 'Aquarium ${s.aquariumId}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSensorRow(
                  'Temperature',
                  '${s.sensor.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  'pH',
                  s.sensor.ph.toStringAsFixed(2),
                  Icons.water_drop,
                ),
                const SizedBox(height: 8),
                _buildSensorRow(
                  'Turbidity',
                  '${s.sensor.turbidity.toStringAsFixed(1)} NTU',
                  Icons.visibility,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.dashboard, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
