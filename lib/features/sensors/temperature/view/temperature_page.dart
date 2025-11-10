import 'package:aquacare_v5/utils/theme.dart' as theme;
import 'package:aquacare_v5/utils/responsive_helper.dart';
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
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

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

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Temperature • ${widget.aquariumName}'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          fontSize: ResponsiveHelper.getFontSize(context, 24),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context),
          vertical: ResponsiveHelper.verticalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Notification Toggle
            Container(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 12, bottom: 12, left: 25, right: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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

                          // ✅ COLORS WHEN SWITCH IS ON
                          activeColor:
                              Theme.of(context).colorScheme.primary, // thumb
                          activeTrackColor:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondary, // track
                          // ✅ COLORS WHEN SWITCH IS OFF
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.primary,
                          inactiveTrackColor:
                              Theme.of(context).colorScheme.onSecondary,
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
                _minController.value = TextEditingValue(
                  text: min.toStringAsFixed(1),
                  selection: TextSelection.collapsed(
                    offset: min.toStringAsFixed(1).length,
                  ),
                );
                _maxController.value = TextEditingValue(
                  text: max.toStringAsFixed(1),
                  selection: TextSelection.collapsed(
                    offset: max.toStringAsFixed(1).length,
                  ),
                );
                final bool isDark =
                    Theme.of(context).brightness == Brightness.dark;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _temperatureSelector(min, _minController, (value) {
                      setState(() => _minTempEditing = value);
                    }),
                    const SizedBox(width: 10),
                    const Text(' - '),
                    const SizedBox(width: 10),
                    _temperatureSelector(max, _maxController, (value) {
                      setState(() => _maxTempEditing = value);
                    }),
                    const SizedBox(width: 20),
                    Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 20,
                        color:
                            isDark
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Always parse latest on-screen text to save even without keyboard confirm
                        final parsedMin = double.tryParse(_minController.text);
                        final parsedMax = double.tryParse(_maxController.text);
                        final newMin =
                            parsedMin ?? _minTempEditing ?? range.min;
                        final newMax =
                            parsedMax ?? _maxTempEditing ?? range.max;
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
                      child: Text(
                        'SET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                        ),
                      ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: Size(
                  ResponsiveHelper.getCardWidth(context),
                  ResponsiveHelper.getCardHeight(context) / 3.5,
                ),
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

            Container(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 12, bottom: 12, left: 25, right: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Note: Default aquarium temperature for fishes are 26-28°C.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _temperatureSelector(
    double value,
    TextEditingController controller,
    Function(double) onChanged,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
            cursorColor: isDark ? Colors.white : Colors.black,
            style: TextStyle(
              color:
                  isDark
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            textAlign: TextAlign.center,
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
            if (value > 0) onChanged(value - 1);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
