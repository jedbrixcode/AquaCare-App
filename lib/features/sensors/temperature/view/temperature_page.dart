import 'package:aquacare_v5/utils/theme.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/sensors/temperature/viewmodel/temperature_viewmodel.dart';

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor:
            isDark
                ? darkTheme.appBarTheme.backgroundColor
                : lightTheme.appBarTheme.backgroundColor,
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
                color: Theme.of(context).colorScheme.secondary,
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

                          activeColor:
                              isDark
                                  ? darkTheme.colorScheme.primary
                                  : lightTheme.colorScheme.background,
                          activeTrackColor:
                              isDark
                                  ? lightTheme.colorScheme.primary
                                  : darkTheme.colorScheme.background,
                          inactiveThumbColor:
                              isDark
                                  ? darkTheme.colorScheme.primary
                                  : lightTheme.colorScheme.background,
                          inactiveTrackColor:
                              isDark
                                  ? lightTheme.colorScheme.primary
                                  : darkTheme.colorScheme.background,
                        ),

                    loading:
                        () => SizedBox(
                          height: ResponsiveHelper.getCardHeight(context) / 10,
                          width: ResponsiveHelper.getCardWidth(context) / 10,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),

                    error: (e, _) => const Icon(Icons.error, color: Colors.red),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 14),

            // Temperature Display
            rangeAsync.when(
              data: (range) {
                final min = _minTempEditing ?? range.min;
                final max = _maxTempEditing ?? range.max;
                return tempAsync.when(
                  data: (temp) {
                    final Color color;
                    if (temp > max || temp < min) {
                      color = const Color.fromRGBO(244, 67, 54, 1);
                    } else {
                      color = const Color.fromRGBO(76, 175, 80, 1);
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
                      child: Center(
                        child: Text(
                          'CURRENT TEMPERATURE: ${temp.toStringAsFixed(0)}°C',
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
                          'CURRENT TEMPERATURE: Loading...',
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
                          'CURRENT TEMPERATURE: Error',
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
            // Temperature Selector + Set
            rangeAsync.when(
              data: (range) {
                final min = _minTempEditing ?? range.min;
                final max = _maxTempEditing ?? range.max;

                // Update controllers with formatted values
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

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            // MIN Temperature
                            Column(
                              children: [
                                Text(
                                  'MIN TEMP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      18,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _temperatureSelector(
                                  min,
                                  _minController,
                                  (value) =>
                                      setState(() => _minTempEditing = value),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: ResponsiveHelper.horizontalPadding(
                                context,
                              ),
                            ),
                            Text(
                              '—',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  20,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.horizontalPadding(
                                context,
                              ),
                            ),
                            // MAX Temperature
                            Column(
                              children: [
                                Text(
                                  'MAX TEMP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      18,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _temperatureSelector(
                                  max,
                                  _maxController,
                                  (value) =>
                                      setState(() => _maxTempEditing = value),
                                ),
                              ],
                            ),
                            SizedBox(
                              width:
                                  ResponsiveHelper.horizontalPadding(context) /
                                  14,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: ResponsiveHelper.horizontalPadding(
                                    context,
                                  ),
                                ),
                                Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      35,
                                    ),
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      ResponsiveHelper.horizontalPadding(
                                        context,
                                      ) +
                                      16,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // SET button
                        ElevatedButton(
                          onPressed: () async {
                            // Always parse latest on-screen text to save even without keyboard confirm
                            final parsedMin = double.tryParse(
                              _minController.text,
                            );
                            final parsedMax = double.tryParse(
                              _maxController.text,
                            );

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
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => SizedBox.shrink(),
              error: (e, _) => SizedBox.shrink(),
            ),

            SizedBox(height: ResponsiveHelper.verticalPadding(context) / 12),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: ResponsiveHelper.verticalPadding(context)),
            // Set Default Button
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
                const int defaultMinTemp = 26;
                const int defaultMaxTemp = 28;
                await vm.setTemperatureRange(
                  aquariumId: widget.aquariumId,
                  min: defaultMinTemp.toDouble(),
                  max: defaultMaxTemp.toDouble(),
                );
                ref.invalidate(temperatureThresholdProvider(widget.aquariumId));
              },
              child: Text(
                'SET TO DEFAULT TEMPERATURE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getFontSize(context, 18),
                ),
              ),
            ),

            Spacer(),

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
            SizedBox(height: ResponsiveHelper.verticalPadding(context) + 8),
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
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => onChanged(value + 1),
          icon: Icon(
            Icons.arrow_drop_up,
            size: ResponsiveHelper.getFontSize(context, 40),
          ),
        ),
        SizedBox(
          width: ResponsiveHelper.getCardWidth(context) / 5,
          height: ResponsiveHelper.getCardHeight(context) / 3.5,
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
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              // ✅ Called when user presses done
              final parsed = double.tryParse(text);
              if (parsed != null) {
                onChanged(parsed);
              }
              FocusScope.of(context).unfocus(); // ✅ Dismiss keyboard
            },
            onTapOutside: (event) {
              // ✅ Called when user clicks away
              final parsed = double.tryParse(controller.text);
              if (parsed != null) {
                onChanged(parsed);
              }
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      isDark
                          ? darkTheme.colorScheme.primary
                          : lightTheme.colorScheme.primary,
                ),
              ),
              filled: true, // Enable background color
              fillColor:
                  isDark
                      ? Colors.blueGrey[700] // dark mode background
                      : Colors.blueGrey[100], // light mode background
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (value > 0) onChanged(value - 1);
          },
          icon: const Icon(Icons.arrow_drop_down, size: 40),
        ),
      ],
    );
  }
}
