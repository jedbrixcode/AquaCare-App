import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../viewmodel/ph_viewmodel.dart';

class PhPage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const PhPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<PhPage> createState() => _PhPageState();
}

class _PhPageState extends ConsumerState<PhPage> {
  double? _minPhEditing;
  double? _maxPhEditing;

  @override
  Widget build(BuildContext context) {
    final phAsync = ref.watch(phValueProvider(widget.aquariumId));
    final rangeAsync = ref.watch(phThresholdProvider(widget.aquariumId));
    final notifAsync = ref.watch(phNotificationProvider(widget.aquariumId));
    final vm = ref.watch(phViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('pH Level • ${widget.aquariumName}'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          children: [
            // Notification Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NOTIFICATION',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  notifAsync.when(
                    data:
                        (enabled) => Switch(
                          value: enabled,
                          onChanged: (value) async {
                            await vm.setPhNotification(
                              aquariumId: widget.aquariumId,
                              enabled: value,
                            );
                            ref.invalidate(
                              phNotificationProvider(widget.aquariumId),
                            );
                          },
                        ),
                    loading:
                        () => const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    error: (e, _) => const Icon(Icons.error, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current pH Display
            rangeAsync.when(
              data: (range) {
                return phAsync.when(
                  data: (ph) {
                    Color color;
                    if (ph > range.max) {
                      color = Colors.red;
                    } else if (ph < range.min) {
                      color = Colors.blue;
                    } else {
                      color = Colors.green;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 70,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'CURRENT pH: ${ph.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  loading:
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 70,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'CURRENT pH: Loading...',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                  error:
                      (e, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 70,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'CURRENT pH: Error',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                );
              },
              loading:
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 70,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Loading thresholds...',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
              error:
                  (e, _) => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 70,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Error loading thresholds',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
            ),
            const SizedBox(height: 10),

            // Threshold Controls
            rangeAsync.when(
              data: (range) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'MIN pH',
                              style: TextStyle(fontSize: 16),
                            ),
                            _buildNumberInput(
                              value: _minPhEditing ?? range.min,
                              onChanged:
                                  (value) =>
                                      setState(() => _minPhEditing = value),
                            ),
                          ],
                        ),
                        const Text(
                          'pH',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            const Text(
                              'MAX pH',
                              style: TextStyle(fontSize: 16),
                            ),
                            _buildNumberInput(
                              value: _maxPhEditing ?? range.max,
                              onChanged:
                                  (value) =>
                                      setState(() => _maxPhEditing = value),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final newMin = _minPhEditing ?? range.min;
                            final newMax = _maxPhEditing ?? range.max;
                            await vm.setPhRange(
                              aquariumId: widget.aquariumId,
                              min: newMin,
                              max: newMax,
                            );
                            setState(() {
                              _minPhEditing = null;
                              _maxPhEditing = null;
                            });
                            ref.invalidate(
                              phThresholdProvider(widget.aquariumId),
                            );
                          },
                          child: const Text('SET'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        const double defaultMinPh = 6.5;
                        const double defaultMaxPh = 7.5;
                        await vm.setPhRange(
                          aquariumId: widget.aquariumId,
                          min: defaultMinPh,
                          max: defaultMaxPh,
                        );
                        ref.invalidate(phThresholdProvider(widget.aquariumId));
                      },
                      child: const Text('SET DEFAULT'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) =>
                      const Center(child: Text('Error loading thresholds')),
            ),
            const Spacer(),
            const Text(
              'Note: Default aquarium pH for fishes are 6.5-7.5.',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged(value + 0.1),
          icon: const Icon(Icons.arrow_drop_up, size: 40),
        ),
        SizedBox(
          width: 70,
          child: TextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(text: value.toStringAsFixed(1)),
            onChanged: (text) {
              final parsed = double.tryParse(text);
              if (parsed != null) onChanged(parsed);
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (value > 0) onChanged(value - 0.1);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
