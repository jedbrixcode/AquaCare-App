import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import '../viewmodel/turbidity_viewmodel.dart';
import 'package:aquacare_v5/utils/theme.dart';

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

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? darkTheme.colorScheme.background : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDark
                ? darkTheme.appBarTheme.backgroundColor
                : lightTheme.appBarTheme.backgroundColor,
        title: Text(
          'Water Turbidity • ${widget.aquariumName}',
          style: TextStyle(
            color:
                isDark
                    ? darkTheme.appBarTheme.titleTextStyle?.color
                    : lightTheme.appBarTheme.titleTextStyle?.color,
            fontSize: ResponsiveHelper.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        titleTextStyle: TextStyle(
          color:
              isDark
                  ? darkTheme.appBarTheme.titleTextStyle?.color
                  : Colors.white,
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
                color: isDark ? darkTheme.colorScheme.primary : Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NOTIFICATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getFontSize(context, 24),
                      fontWeight: FontWeight.bold,
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
                          activeColor:
                              isDark
                                  ? darkTheme.colorScheme.primary
                                  : Colors.blue,
                          activeTrackColor:
                              isDark
                                  ? darkTheme.colorScheme.onSecondary
                                  : Colors.blue,
                          inactiveThumbColor:
                              isDark
                                  ? darkTheme.colorScheme.primary
                                  : Colors.blue,
                          inactiveTrackColor:
                              isDark
                                  ? darkTheme.colorScheme.onSecondary
                                  : Colors.blue,
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
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),

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
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.verticalPadding(context),
                            horizontal:
                                ResponsiveHelper.horizontalPadding(context) +
                                24,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'CURRENT TURBIDITY: ${turbidity.toStringAsFixed(1)} NTU',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.verticalPadding(context) + 8,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.verticalPadding(context),
                            horizontal: ResponsiveHelper.horizontalPadding(
                              context,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color, width: 1),
                          ),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                18,
                              ),
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
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.verticalPadding(context),
                          horizontal:
                              ResponsiveHelper.horizontalPadding(context) + 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CURRENT TURBIDITY: Loading...',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 18),
                            color: Colors.white,
                          ),
                        ),
                      ),
                  error:
                      (e, _) => Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.verticalPadding(context),
                          horizontal:
                              ResponsiveHelper.horizontalPadding(context) + 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'CURRENT TURBIDITY: Error',
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
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.verticalPadding(context),
                      horizontal:
                          ResponsiveHelper.horizontalPadding(context) + 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Loading thresholds...',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
              error:
                  (e, _) => Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.verticalPadding(context),
                      horizontal:
                          ResponsiveHelper.horizontalPadding(context) + 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Error loading thresholds',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 5),

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
                            Text(
                              'MIN NTU',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
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
                        Text(
                          'NTU',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              'MAX NTU',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
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
                        SizedBox(
                          width:
                              ResponsiveHelper.horizontalPadding(context) + 24,
                        ),
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
                          child: Text(
                            'SET',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.verticalPadding(context) + 8,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? darkTheme.colorScheme.primary
                                : lightTheme.colorScheme.primary,
                        minimumSize: Size(
                          ResponsiveHelper.getCardWidth(context) / 1,
                          ResponsiveHelper.getCardHeight(context) / 5,
                        ),
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
                      child: Text(
                        'SET DEFAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading:
                  () => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          isDark
                              ? darkTheme.colorScheme.primary
                              : lightTheme.colorScheme.primary,
                    ),
                  ),
              error:
                  (e, _) => Center(
                    child: Text(
                      'Error loading thresholds',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
            Spacer(),
            Container(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Note: NTU (Nephelometric Turbidity Units) measures water clarity.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 12),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 12),
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
            cursorColor:
                isDark
                    ? darkTheme.textTheme.bodyMedium?.color
                    : lightTheme.textTheme.bodyMedium?.color,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      isDark
                          ? darkTheme.colorScheme.primary
                          : lightTheme.colorScheme.primary,
                ),
              ),
              filled: true, // ✅ Enable background color
              fillColor:
                  isDark
                      ? Colors.blueGrey[700] // dark mode background
                      : Colors.blueGrey[100], // light mode background
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
