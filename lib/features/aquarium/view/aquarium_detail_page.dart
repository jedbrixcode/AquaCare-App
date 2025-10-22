import 'package:aquacare_v5/features/aquarium/viewmodel/aquarium_dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/features/autofeed/view/autofeed_camera_page.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart' as aq;
import 'package:aquacare_v5/features/scheduled_autofeed/view/scheduled_autofeed_page.dart';
import 'package:aquacare_v5/features/sensors/temperature/view/temperature_page.dart'
    as mvvm_temp;
import 'package:aquacare_v5/features/sensors/ph/view/ph_page.dart' as mvvm_ph;
import 'package:aquacare_v5/features/sensors/turbidity/view/turbidity_page.dart'
    as mvvm_turbidity;
import 'package:aquacare_v5/features/aquarium/viewmodel/aquarium_detail_viewmodel.dart'
    as viewmodel;
import 'package:aquacare_v5/utils/responsive_helper.dart';

class AquariumDetailPage extends ConsumerStatefulWidget {
  final String aquariumId;
  final String aquariumName;

  const AquariumDetailPage({
    super.key,
    required this.aquariumId,
    required this.aquariumName,
  });

  @override
  ConsumerState<AquariumDetailPage> createState() => _AquariumDetailPageState();
}

class _AquariumDetailPageState extends ConsumerState<AquariumDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Watch EXISTING providers from aquarium_dashboard_viewmodel.dart
    final sensorAsync = ref.watch(aquariumSensorProvider(widget.aquariumId));
    final thresholdAsync = ref.watch(
      aquariumThresholdProvider(widget.aquariumId),
    );

    // Watch OUR ViewModel for computed state
    final viewModelState = ref.watch(
      viewmodel.aquariumDetailViewModelProvider(widget.aquariumId),
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Update ViewModel when sensor changes
    sensorAsync.whenData((sensor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .updateSensor(sensor);
      });
    });

    // Update ViewModel when threshold changes
    thresholdAsync.whenData((threshold) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .updateThreshold(threshold);

        // Set defaults if needed - using EXISTING dashboard viewmodel
        if (threshold.tempMin == 0 && threshold.tempMax == 0) {
          _setDefaultThresholds();
        }
      });
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.aquariumName} Dashboard"),
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          fontSize: ResponsiveHelper.getFontSize(context, 25),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        toolbarHeight: ResponsiveHelper.isMobile(context) ? 70 : 100,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child:
            ResponsiveHelper.isMobile(context)
                ? _buildMobileLayout(viewModelState, theme, isDark)
                : _buildDesktopLayout(viewModelState, theme, isDark),
      ),
    );
  }

  // Use EXISTING repository through dashboard viewmodel
  void _setDefaultThresholds() {
    final defaultThreshold = aq.Threshold(
      tempMin: 22.0,
      tempMax: 28.0,
      phMin: 6.5,
      phMax: 7.5,
      turbidityMin: 3.0,
      turbidityMax: 52.0,
    );
    ref
        .read(aquariumDashboardViewModelProvider)
        .setThresholds(widget.aquariumId, defaultThreshold);
  }

  Widget _buildMobileLayout(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      spacing: ResponsiveHelper.getScreenPadding(context).top,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTemperatureCard(viewModelState, theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
              _buildAutoFeedCard(theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
              _buildHealthBar(viewModelState, theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTurbidityCard(viewModelState, theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
              _buildPhCard(viewModelState, theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
              _buildScheduledAutofeedCard(theme, isDark),
              SizedBox(height: ResponsiveHelper.getScreenPadding(context).top),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftColumn(viewModelState, theme, isDark),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: _buildRightColumn(viewModelState, theme, isDark),
        ),
      ],
    );
  }

  Widget _buildLeftColumn(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildTemperatureCard(viewModelState, theme, isDark),
        const SizedBox(height: 20),
        _buildAutoFeedCard(theme, isDark),
        const SizedBox(height: 20),
        _buildHealthBar(viewModelState, theme, isDark),
      ],
    );
  }

  Widget _buildRightColumn(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildTurbidityCard(viewModelState, theme, isDark),
        const SizedBox(height: 20),
        _buildPhCard(viewModelState, theme, isDark),
        const SizedBox(height: 20),
        _buildScheduledAutofeedCard(theme, isDark),
      ],
    );
  }

  Widget _buildScheduledAutofeedCard(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ScheduledAutofeedPage(
                    aquariumId: widget.aquariumId,
                    aquariumName: widget.aquariumName,
                  ),
            ),
          ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context),
          vertical: ResponsiveHelper.getScreenPadding(context).top,
        ),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? theme.colorScheme.primary : Colors.blue[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Scheduled Autofeeding',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 15),
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? theme.colorScheme.onSurface
                              : Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage feeding schedules',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 10),
                      color:
                          isDark
                              ? theme.textTheme.bodyMedium?.color
                              : Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    final tempInRange =
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .isTempInRange();
    final tempColor = tempInRange ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => mvvm_temp.TemperaturePage(
                  aquariumId: widget.aquariumId,
                  aquariumName: widget.aquariumName,
                ),
          ),
        );
      },
      child: _bigCircleCard(
        label: "Temperature",
        value: "${viewModelState.sensor.temperature.toStringAsFixed(1)}°C",
        percent: viewModelState.tempHealth,
        icon: FontAwesomeIcons.temperatureHigh,
        ringColor: tempColor,
        color: isDark ? theme.colorScheme.onSurface : Colors.white,
        height: ResponsiveHelper.getCardHeight(context) + 100,
        theme: theme,
        isDark: isDark,
      ),
    );
  }

  Widget _buildTurbidityCard(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    final turbidityInRange =
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .isTurbidityInRange();
    final turbidityColor = turbidityInRange ? Colors.green : Colors.red;

    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => mvvm_turbidity.TurbidityPage(
                    aquariumId: widget.aquariumId,
                    aquariumName: widget.aquariumName,
                  ),
            ),
          ),
      child: _horizontalBarCard(
        label: "Turbidity",
        percent: viewModelState.turbidityHealth,
        color: turbidityColor,
        rawValue: viewModelState.sensor.turbidity,
        theme: theme,
        isDark: isDark,
      ),
    );
  }

  Widget _buildPhCard(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    final phInRange =
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .isPhInRange();
    final phColor = phInRange ? Colors.green : Colors.red;

    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => mvvm_ph.PhPage(
                    aquariumId: widget.aquariumId,
                    aquariumName: widget.aquariumName,
                  ),
            ),
          ),
      child: _circleCard(
        label: "pH level",
        value: viewModelState.sensor.ph.toStringAsFixed(2),
        percent: viewModelState.phHealth,
        icon: FontAwesomeIcons.vialCircleCheck,
        ringColor: phColor,
        color: isDark ? theme.colorScheme.onSurface : Colors.white,
        height: ResponsiveHelper.getCardHeight(context) + 100,
        width: double.infinity,
        theme: theme,
        isDark: isDark,
      ),
    );
  }

  Widget _buildAutoFeedCard(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CameraPage(
                    aquariumId: widget.aquariumId,
                    aquariumName: widget.aquariumName,
                  ),
            ),
          ),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? theme.colorScheme.primary : Colors.green[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto Feeding',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 15),
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? theme.colorScheme.onSurface
                              : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure feeding system',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 10),
                      color:
                          isDark
                              ? theme.textTheme.bodyMedium?.color
                              : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar(
    viewmodel.AquariumDetailState viewModelState,
    ThemeData theme,
    bool isDark,
  ) {
    final wqi = viewModelState.health;
    final bool isGood = wqi >= 51.0;
    final Color barColor = isGood ? Colors.green : Colors.red;
    final String status =
        ref
            .read(
              viewmodel
                  .aquariumDetailViewModelProvider(widget.aquariumId)
                  .notifier,
            )
            .getHealthStatus();

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : barColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.colorScheme.primary : barColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aquarium Health',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 15),
              fontWeight: FontWeight.bold,
              color: isDark ? theme.colorScheme.onSurface : barColor,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LinearProgressIndicator(
              value: wqi / 100.0,
              minHeight: 18,
              backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              color: barColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "${wqi.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: isDark ? theme.colorScheme.onSurface : barColor,
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getFontSize(context, 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI Helper Widgets
  Widget _bigCircleCard({
    required String label,
    required String value,
    required double percent,
    required IconData icon,
    Color? ringColor,
    required Color color,
    required double height,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.colorScheme.surface
                : ringColor?.withOpacity(0.1) ?? Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? theme.colorScheme.primary
                  : ringColor ?? Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: ResponsiveHelper.isMobile(context) ? 60 : 70,
            lineWidth: ResponsiveHelper.isMobile(context) ? 12 : 16,
            percent: percent.clamp(0.0, 1.0),
            center: Icon(
              icon,
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
              size: ResponsiveHelper.isMobile(context) ? 40 : 48,
            ),
            progressColor: ringColor ?? Colors.blue,
            backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 36),
              fontWeight: FontWeight.bold,
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleCard({
    required String label,
    required String value,
    required double percent,
    required IconData icon,
    Color? ringColor,
    required Color color,
    required double height,
    required double width,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.colorScheme.surface
                : ringColor?.withOpacity(0.1) ?? Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? theme.colorScheme.primary
                  : ringColor ?? Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getFontSize(context, 28),
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: ResponsiveHelper.isMobile(context) ? 60 : 70,
            lineWidth: ResponsiveHelper.isMobile(context) ? 12 : 16,
            percent: percent.clamp(0.0, 1.0),
            center: Icon(
              icon,
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
              size: ResponsiveHelper.isMobile(context) ? 40 : 48,
            ),
            progressColor: ringColor ?? Colors.blue,
            backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 34),
              fontWeight: FontWeight.bold,
              color:
                  isDark
                      ? theme.colorScheme.onSurface
                      : ringColor ?? Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalBarCard({
    required String label,
    required double percent,
    required double rawValue,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.colorScheme.primary : color,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getFontSize(context, 18),
                  color: isDark ? theme.colorScheme.onSurface : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor:
                      isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  color: color,
                  minHeight: 20,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${rawValue.toStringAsFixed(0)} NTU",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
