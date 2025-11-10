import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../viewmodel/turbidity_viewmodel.dart';

class TurbidityPage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const TurbidityPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<TurbidityPage> createState() => _TurbidityPageState();
}

class _TurbidityPageState extends ConsumerState<TurbidityPage> {
  double? _minTurbidityEditing;
  double? _maxTurbidityEditing;
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Color getTurbidityColor(double? turbidityValue) {
    switch (turbidityValue) {
      case null:
        return Colors.grey;
      case < 5:
        return Colors.green;
      case < 20:
        return Colors.lightGreen;
      case < 40:
        return Colors.yellow;
      case < 70:
        return Colors.orange;
      case < 101:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  String getTurbidityDescription(double? turbidityValue) {
    switch (turbidityValue) {
      case null:
        return "Loading...";
      case < 5:
        return "Crystal Clear";
      case < 20:
        return "Slightly Cloudy";
      case < 40:
        return "Moderately Cloudy";
      case < 70:
        return "Very Cloudy";
      case < 101:
        return "Extremely Cloudy";
      default:
        return "Extremely Cloudy";
    }
  }

  @override
  Widget build(BuildContext context) {
    final turbidityAsync = ref.watch(turbidityValueProvider(widget.aquariumId));
    final rangeAsync = ref.watch(turbidityThresholdProvider(widget.aquariumId));
    final notifAsync = ref.watch(
      turbidityNotificationProvider(widget.aquariumId),
    );
    final vm = ref.watch(turbidityViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Water Turbidity • ${widget.aquariumName}'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: ResponsiveHelper.getFontSize(context, 24),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: ResponsiveHelper.getScreenPadding(
          context,
        ).copyWith(top: 12, bottom: 12),
        child: Column(
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
                  Text(
                    'NOTIFICATION',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                    ),
                  ),
                  notifAsync.when(
                    data:
                        (enabled) => Switch(
                          value: enabled,
                          onChanged: (value) async {
                            await vm.setTurbidityNotification(
                              aquariumId: widget.aquariumId,
                              enabled: value,
                            );
                            ref.invalidate(
                              turbidityNotificationProvider(widget.aquariumId),
                            );
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.onSecondary,
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
            SizedBox(height: ResponsiveHelper.verticalPadding(context)),

            // Current Turbidity Display
            rangeAsync.when(
              data: (range) {
                return turbidityAsync.when(
                  data: (turbidity) {
                    final color = getTurbidityColor(turbidity);
                    final description = getTurbidityDescription(turbidity);

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 70,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'CURRENT TURBIDITY: ${turbidity.toStringAsFixed(1)} NTU',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 1),
                          ),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
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
                          'CURRENT TURBIDITY: Loading...',
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
                          'CURRENT TURBIDITY: Error',
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
            const SizedBox(height: 20),

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
                              'MIN NTU',
                              style: TextStyle(fontSize: 16),
                            ),
                            _buildNumberInput(
                              value: _minTurbidityEditing ?? range.min,
                              controller: _minController,
                              onChanged:
                                  (value) => setState(
                                    () => _minTurbidityEditing = value,
                                  ),
                              step: 1,
                            ),
                          ],
                        ),
                        const Text(
                          'NTU',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            const Text(
                              'MAX NTU',
                              style: TextStyle(fontSize: 16),
                            ),
                            _buildNumberInput(
                              value: _maxTurbidityEditing ?? range.max,
                              controller: _maxController,
                              onChanged:
                                  (value) => setState(
                                    () => _maxTurbidityEditing = value,
                                  ),
                              step: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final newMin = _minTurbidityEditing ?? range.min;
                            final newMax = _maxTurbidityEditing ?? range.max;
                            await vm.setTurbidityRange(
                              aquariumId: widget.aquariumId,
                              min: newMin,
                              max: newMax,
                            );
                            setState(() {
                              _minTurbidityEditing = null;
                              _maxTurbidityEditing = null;
                            });
                            ref.invalidate(
                              turbidityThresholdProvider(widget.aquariumId),
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
                        const double defaultMinTurbidity = 3;
                        const double defaultMaxTurbidity = 52;
                        await vm.setTurbidityRange(
                          aquariumId: widget.aquariumId,
                          min: defaultMinTurbidity,
                          max: defaultMaxTurbidity,
                        );
                        ref.invalidate(
                          turbidityThresholdProvider(widget.aquariumId),
                        );
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
              'Note: NTU (Nephelometric Turbidity Units) measures water clarity.',
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
    required TextEditingController controller,
    required Function(double) onChanged,
    double step = 1.0,
  }) {
    controller.value = TextEditingValue(
      text: value.toStringAsFixed(0),
      selection: TextSelection.collapsed(
        offset: value.toStringAsFixed(0).length,
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged(value + step),
          icon: const Icon(Icons.arrow_drop_up, size: 40),
        ),
        SizedBox(
          width: 70,
          child: TextField(
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
            if (value > 0) onChanged(value - step);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
