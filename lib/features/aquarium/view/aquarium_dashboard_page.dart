import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/aquarium_dashboard_viewmodel.dart';

class AquariumDashboardPage extends ConsumerWidget {
  const AquariumDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorAsync = ref.watch(sensorProvider);
    // TODO: Add connectivity check and show persistent offline warning if needed
    return Scaffold(
      appBar: AppBar(title: const Text('Aquarium 1 Dashboard')),
      body: sensorAsync.when(
        data:
            (sensor) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperature: 6C: ${sensor.temperature.toStringAsFixed(1)}',
                  ),
                  Text('pH: ${sensor.ph.toStringAsFixed(2)}'),
                  Text('Turbidity: ${sensor.turbidity.toStringAsFixed(1)} NTU'),
                  // TODO: Add more UI and controls as needed
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
