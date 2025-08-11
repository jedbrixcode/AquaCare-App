import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/sensors/temperature/viewmodel/temperature_viewmodel.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';

class TemperaturePage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;
  const TemperaturePage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends ConsumerState<TemperaturePage> {
  double? _minTempEditing;
  double? _maxTempEditing;

  @override
  Widget build(BuildContext context) {
    final tempAsync = ref.watch(temperatureValueProvider(widget.aquariumId));
    final rangeAsync = ref.watch(
      temperatureThresholdProvider(widget.aquariumId),
    );
    final notifAsync = ref.watch(
      temperatureNotificationProvider(widget.aquariumId),
    );
    final vm = ref.watch(temperatureViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Temperature • ${widget.aquariumName}'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                            await vm.setTemperatureNotification(
                              aquariumId: widget.aquariumId,
                              enabled: value,
                            );
                            ref.invalidate(
                              temperatureNotificationProvider(
                                widget.aquariumId,
                              ),
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
            const SizedBox(height: 12),

            // Temperature Display
            rangeAsync.when(
              data: (range) {
                final min = _minTempEditing ?? range.min;
                final max = _maxTempEditing ?? range.max;
                return tempAsync.when(
                  data: (temp) {
                    final Color color;
                    if (temp > max) {
                      color = Colors.red[500]!;
                    } else if (temp < min) {
                      color = Colors.blue[500]!;
                    } else {
                      color = Colors.green[300]!;
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
                        'CURRENT TEMPERATURE: ${temp.toStringAsFixed(0)}°C',
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
                          'CURRENT TEMPERATURE: Loading...',
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
                          'CURRENT TEMPERATURE: Error',
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

            // Temperature Selector + Set
            rangeAsync.when(
              data: (range) {
                final min = _minTempEditing ?? range.min;
                final max = _maxTempEditing ?? range.max;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _temperatureSelector(min, (value) {
                      setState(() => _minTempEditing = value);
                    }),
                    const SizedBox(width: 10),
                    const Text(' - '),
                    const SizedBox(width: 10),
                    _temperatureSelector(max, (value) {
                      setState(() => _maxTempEditing = value);
                    }),
                    const SizedBox(width: 20),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final newMin = _minTempEditing ?? range.min;
                        final newMax = _maxTempEditing ?? range.max;
                        await vm.setTemperatureRange(
                          aquariumId: widget.aquariumId,
                          min: newMin,
                          max: newMax,
                        );
                        setState(() {
                          _minTempEditing = null;
                          _maxTempEditing = null;
                        });
                        ref.invalidate(
                          temperatureThresholdProvider(widget.aquariumId),
                        );
                      },
                      child: const Text('SET'),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 5),

            // Set Default Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                const int defaultMinTemp = 26;
                const int defaultMaxTemp = 28;
                await vm.setTemperatureRange(
                  aquariumId: widget.aquariumId,
                  min: defaultMinTemp.toDouble(),
                  max: defaultMaxTemp.toDouble(),
                );
                ref.invalidate(temperatureThresholdProvider(widget.aquariumId));
              },
              child: const Text('SET TO DEFAULT TEMPERATURE'),
            ),

            const Spacer(),

            const Text(
              'Note: Default aquarium temperature for fishes are 26-28°C.',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _temperatureSelector(double value, Function(double) onChanged) {
    final controller = TextEditingController(text: value.toString());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.arrow_drop_up, size: 40),
        ),
        SizedBox(
          width: 70,
          height: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onSubmitted: (text) {
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
            if (value > 0) onChanged(value - 1);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
