import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as perms;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../aquarium/view/aquarium_dashboard_page.dart';
import '../viewmodel/splash_viewmodel.dart';
import '../../../utils/theme.dart' as theme;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
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
        bool isDark = Theme.of(dialogContext).brightness == Brightness.dark;
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
                              ? theme.darkTheme.textTheme.bodyMedium?.color
                              : theme.lightTheme.textTheme.bodyMedium?.color,
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
                            ? theme.darkTheme.textTheme.bodyMedium?.color
                            : theme.lightTheme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? theme.darkTheme.colorScheme.surface
                            : Colors.blue[50],
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
                                    ? theme
                                        .darkTheme
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : theme
                                        .lightTheme
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Allow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        bool isDark = Theme.of(dialogContext).brightness == Brightness.dark;
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
                      ? theme.darkTheme.textTheme.bodyMedium?.color
                      : theme.lightTheme.textTheme.bodyMedium?.color,
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
                          ? theme.darkTheme.textTheme.bodyMedium?.color
                          : theme.lightTheme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
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
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'What won\'t work:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.lightTheme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
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
                Navigator.of(dialogContext).pop();
                // Re-show battery dialog and wait
                _isDialogShowing = true;
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
                          ? theme.lightTheme.colorScheme.primary
                          : theme.darkTheme.colorScheme.primary,
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
                          ? theme.darkTheme.textTheme.bodyMedium?.color
                          : theme.lightTheme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red[700], size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.lightTheme.textTheme.bodyMedium?.color,
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
              Image.asset('assets/icons/aquacare_logo.png', height: 205),
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
