import 'package:aquacare_v5/utils/theme.dart';
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
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phAsync = ref.watch(phValueProvider(widget.aquariumId));
    final rangeAsync = ref.watch(phThresholdProvider(widget.aquariumId));
    final notifAsync = ref.watch(phNotificationProvider(widget.aquariumId));
    final vm = ref.watch(phViewModelProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('pH Level • ${widget.aquariumName}'),
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
                  Text(
                    'NOTIFICATION',
                    style: TextStyle(
                      color:
                          isDark
                              ? darkTheme.textTheme.bodyMedium?.color
                              : lightTheme.textTheme.bodyMedium?.color,
                      fontSize: ResponsiveHelper.getFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
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
                          // Align switch colors to temperature page
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.onSecondary,
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.primary,
                          inactiveTrackColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                    loading:
                        () => SizedBox(
                          height: ResponsiveHelper.getCardHeight(context) / 10,
                          width: ResponsiveHelper.getCardWidth(context) / 10,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    error: (e, _) => const Icon(Icons.error, color: Colors.red),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 14),

            // Current pH Display
            rangeAsync.when(
              data: (range) {
                return phAsync.when(
                  data: (ph) {
                    final Color color;
                    if (ph > range.max) {
                      color = Colors.red[500]!;
                    } else if (ph < range.min) {
                      color = Colors.blue[500]!;
                    } else {
                      color = Colors.green[300]!;
                    }
                    return Container(
                      width: double.infinity,
                      height: ResponsiveHelper.getCardHeight(context) / 3.5,
                      padding: EdgeInsets.all(
                        ResponsiveHelper.verticalPadding(context) + 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'CURRENT pH: ${ph.toStringAsFixed(1)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  loading:
                      () => Container(
                        width: double.infinity,
                        height: ResponsiveHelper.getCardHeight(context) / 3.5,
                        padding: EdgeInsets.all(
                          ResponsiveHelper.verticalPadding(context) + 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CURRENT pH: Loading...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 18),
                            color: Colors.white,
                          ),
                        ),
                      ),
                  error:
                      (e, _) => Container(
                        width: double.infinity,
                        height: ResponsiveHelper.getCardHeight(context) / 3.5,
                        padding: EdgeInsets.all(
                          ResponsiveHelper.verticalPadding(context) + 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CURRENT pH: Error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 18),
                            color: Colors.white,
                          ),
                        ),
                      ),
                );
              },
              loading:
                  () => Container(
                    width: double.infinity,
                    height: ResponsiveHelper.getCardHeight(context) / 3.5,
                    padding: EdgeInsets.all(
                      ResponsiveHelper.verticalPadding(context) + 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Loading thresholds...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
              error:
                  (e, _) => Container(
                    width: double.infinity,
                    height: ResponsiveHelper.getCardHeight(context) / 3.5,
                    padding: EdgeInsets.all(
                      ResponsiveHelper.verticalPadding(context) + 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Error loading thresholds',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),

            // Threshold Controls
            rangeAsync.when(
              data: (range) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'MIN pH',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  16,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildNumberInput(
                              value: _minPhEditing ?? range.min,
                              controller: _minController,
                              onChanged:
                                  (value) =>
                                      setState(() => _minPhEditing = value),
                              step: 0.1,
                            ),
                          ],
                        ),
                        SizedBox(
                          width:
                              ResponsiveHelper.horizontalPadding(context) + 16,
                        ),
                        Text(
                          'pH',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            color:
                                isDark
                                    ? darkTheme.textTheme.bodyLarge?.color
                                    : lightTheme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width:
                              ResponsiveHelper.horizontalPadding(context) + 16,
                        ),
                        Column(
                          children: [
                            Text(
                              'MAX pH',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  16,
                                ),
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? darkTheme.textTheme.bodyMedium?.color
                                        : lightTheme
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                              ),
                            ),
                            _buildNumberInput(
                              value: _maxPhEditing ?? range.max,
                              controller: _maxController,
                              onChanged:
                                  (value) =>
                                      setState(() => _maxPhEditing = value),
                              step: 0.1,
                            ),
                          ],
                        ),
                        SizedBox(
                          width:
                              ResponsiveHelper.horizontalPadding(context) + 16,
                        ),
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
                          child: Text(
                            'SET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.verticalPadding(context) / 12,
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: ResponsiveHelper.verticalPadding(context)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(
                          ResponsiveHelper.getCardWidth(context) + 32,
                          ResponsiveHelper.getCardHeight(context) / 3.5,
                        ),
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
                      child: Text(
                        'SET DEFAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) =>
                      const Center(child: Text('Error loading thresholds')),
            ),
            Spacer(),
            Container(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 12, bottom: 12, left: 40, right: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Note: Default aquarium pH for fishes are 6.5-7.5.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    controller.value = TextEditingValue(
      text: value.toStringAsFixed(step < 1 ? 1 : 0),
      selection: TextSelection.collapsed(
        offset: value.toStringAsFixed(step < 1 ? 1 : 0).length,
      ),
    );
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed:
              () => onChanged(
                double.parse((value + step).toStringAsFixed(step < 1 ? 1 : 0)),
              ),
          icon: const Icon(Icons.arrow_drop_up, size: 40),
        ),
        SizedBox(
          width: ResponsiveHelper.getCardWidth(context) / 5,
          height: ResponsiveHelper.getCardHeight(context) / 3.5,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            onChanged: (text) {
              final parsed = double.tryParse(text);
              if (parsed != null) onChanged(parsed);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: isDark ? Colors.blueGrey[700] : Colors.blueGrey[100],
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (value > 0) {
              onChanged(
                double.parse((value - step).toStringAsFixed(step < 1 ? 1 : 0)),
              );
            }
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
