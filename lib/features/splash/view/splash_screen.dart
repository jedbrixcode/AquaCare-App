import 'dart:async';
import 'package:aquacare_v5/core/navigation/route_observer.dart';
import 'package:aquacare_v5/utils/responsive_helper.dart';
import 'package:aquacare_v5/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as perms;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../aquarium/view/aquarium_dashboard_page.dart';
import '../viewmodel/splash_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  bool _initComplete = false;
  bool _timerComplete = false;
  bool _isDialogShowing = false;
  Timer? _minimumDisplayTimer;
  final Duration _minDisplayDuration = const Duration(seconds: 3);
  DateTime? _timerStartedAt;
  Duration? _remainingDisplay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start minimum display timer (3 seconds)
    _timerStartedAt = DateTime.now();
    _minimumDisplayTimer = Timer(_minDisplayDuration, () {
      _timerComplete = true;
      _tryNavigate(); // ✅ Try to navigate when timer completes
    });

    // Safe listener for state changes
    ref.listenManual<AsyncValue<void>>(splashViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          _initComplete = true;
          _tryNavigate(); // ✅ Try to navigate when init completes
        },
        error: (err, _) {
          _initComplete = true;
          _tryNavigate(); // ✅ Try to navigate when init completes
        },
      );
    });

    // Trigger initialization
    Future.microtask(
      () => ref.read(splashViewModelProvider.notifier).initializeApp(),
    );

    // Auto-request battery optimization after short delay
    Future.delayed(
      const Duration(milliseconds: 800),
      _checkAndRequestBatteryOptimization,
    );
  }

  // ✅ NEW: Only navigate when ALL conditions are met
  void _tryNavigate() {
    if (_initComplete && _timerComplete && !_isDialogShowing && mounted) {
      _navigateToDashboard();
    }
  }

  Future<void> _checkAndRequestBatteryOptimization() async {
    if (!mounted) return;

    try {
      final status = await perms.Permission.ignoreBatteryOptimizations.status;

      if (!status.isGranted && mounted) {
        _isDialogShowing = true; // ✅ Mark dialog as showing
        _pauseSplashTimer(); // pause while dialog is shown
        await _showBatteryOptimizationDialog();
      }
    } catch (e) {
      debugPrint('Battery optimization check failed: $e');
    }
  }

  Future<void> _showBatteryOptimizationDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.battery_alert, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Battery Optimization',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? theme.textTheme.bodyMedium?.color
                              : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AquaCare needs to run in the background to send you timely alerts about your aquarium.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color:
                        isDark
                            ? theme.textTheme.bodyMedium?.color
                            : theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap "Allow" to disable battery optimization',
                          style: TextStyle(
                            color:
                                isDark
                                    ? theme.textTheme.bodyMedium?.color
                                    : theme.textTheme.bodyMedium?.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _handleSkipPermission(dialogContext),
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ElevatedButton(
                onPressed: () => _handleAllowPermission(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.horizontalPadding(context) / 2,
                    vertical: ResponsiveHelper.verticalPadding(context) / 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Allow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getFontSize(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isDialogShowing) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // close dialog
      }
      _isDialogShowing = false;
      _resumeSplashTimerIfNeeded();
      _tryNavigate();
    }
  }

  Future<void> _handleAllowPermission(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();

    try {
      final status =
          await perms.Permission.ignoreBatteryOptimizations.request();

      if (!status.isGranted) {
        await perms.openAppSettings();
      }
    } catch (e) {
      debugPrint('Failed to request battery optimization: $e');
      await perms.openAppSettings();
    }
    _isDialogShowing = false;
    _resumeSplashTimerIfNeeded();
    _tryNavigate();
  }

  Future<void> _handleSkipPermission(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();

    if (mounted) {
      await _showSkipWarningDialog();
      _isDialogShowing = false;
      _resumeSplashTimerIfNeeded();
      _tryNavigate();
    }
  }

  Future<void> _showSkipWarningDialog() async {
    final context = globalNavigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 48,
          ),
          title: Text(
            'Limited Functionality',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDark
                      ? theme.textTheme.bodyMedium?.color
                      : theme.textTheme.bodyMedium?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Without battery optimization disabled, AquaCare may not function as expected.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color:
                      isDark
                          ? theme.textTheme.bodyMedium?.color
                          : theme.textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: ResponsiveHelper.verticalPadding(context) / 2),
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.verticalPadding(context),
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.red[50]
                          : const Color.fromARGB(255, 112, 91, 94),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red[700],
                          size: ResponsiveHelper.getFontSize(context, 18),
                        ),
                        SizedBox(
                          width:
                              ResponsiveHelper.horizontalPadding(context) / 2,
                        ),
                        Text(
                          'What won\'t work:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getFontSize(context, 13),
                            color:
                                isDark
                                    ? lightTheme.textTheme.bodyMedium?.color
                                    : darkTheme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.verticalPadding(context) / 2,
                    ),
                    _buildLimitationItem('Real-time notifications'),
                    _buildLimitationItem('Background monitoring'),
                    _buildLimitationItem('Scheduled alerts'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Step 1: Handle permission safely
                await _handleAllowPermission(dialogContext);

                // Step 2: Pop dialog (if still active)
                if (globalNavigatorKey.currentState?.canPop() ?? false) {
                  globalNavigatorKey.currentState?.pop();
                }

                // Step 3: Wait a bit to ensure dialog is closed
                await Future.delayed(const Duration(milliseconds: 200));

                // Step 4: Check if widget is still mounted (avoid calling after dispose)
                if (!mounted) return;

                // Step 5: Mark dialog state
                _isDialogShowing = true;

                // Step 6: Use global navigator context or parent safe context
                final safeContext =
                    globalNavigatorKey.currentContext ?? context;

                await _showBatteryOptimizationDialog();

                _isDialogShowing = false;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Allow Permission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Continue Anyway',
                style: TextStyle(
                  color:
                      isDark
                          ? theme.textTheme.bodyMedium?.color
                          : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLimitationItem(String text) {
    final theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.horizontalPadding(context) / 2,
        bottom: ResponsiveHelper.verticalPadding(context) / 2,
      ),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red[700], size: 14),
          SizedBox(width: ResponsiveHelper.horizontalPadding(context) / 2),
          Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color:
                  isDark
                      ? lightTheme.textTheme.bodyMedium?.color
                      : darkTheme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AquariumDashboardPage()),
    );
  }

  void _pauseSplashTimer() {
    if (_minimumDisplayTimer?.isActive ?? false) {
      _minimumDisplayTimer?.cancel();
      final started = _timerStartedAt;
      if (started != null) {
        final elapsed = DateTime.now().difference(started);
        final remaining = _minDisplayDuration - elapsed;
        _remainingDisplay = remaining.isNegative ? Duration.zero : remaining;
      } else {
        _remainingDisplay = _minDisplayDuration;
      }
    }
  }

  void _resumeSplashTimerIfNeeded() {
    if (_timerComplete) return;
    final remaining = _remainingDisplay;
    if (remaining == null || remaining == Duration.zero) {
      _timerComplete = true;
      return;
    }
    _timerStartedAt = DateTime.now();
    _minimumDisplayTimer = Timer(remaining, () {
      _timerComplete = true;
      _tryNavigate();
    });
    _remainingDisplay = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minimumDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splashViewModelProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 64, 125, 255),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icons/aquacare_logo.png',
                  height: 205,
                ),
              ),
              const SizedBox(height: 16),
              LoadingAnimationWidget.waveDots(color: Colors.white, size: 72),
              const SizedBox(height: 24),
              const Text(
                'Preparing AquaCare...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (state is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Starting in offline mode',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
