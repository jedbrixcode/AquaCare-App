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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Safe listener for state changes
    ref.listenManual<AsyncValue<void>>(splashViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AquariumDashboardPage()),
          );
        },
        error: (err, _) {
          if (!mounted) return;
          // On init failure, proceed to dashboard for offline usage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AquariumDashboardPage()),
          );
        },
      );
    });

    // Trigger initialization
    Future.microtask(
      () => ref.read(splashViewModelProvider.notifier).initializeApp(),
    );
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
              LoadingAnimationWidget.waveDots(color: Colors.white, size: 72),
              const SizedBox(height: 24),
              const Text(
                'Preparing AquaCare...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _BatteryOptimizationPrompt(),
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

class _BatteryOptimizationPrompt extends StatefulWidget {
  @override
  State<_BatteryOptimizationPrompt> createState() =>
      _BatteryOptimizationPromptState();
}

class _BatteryOptimizationPromptState
    extends State<_BatteryOptimizationPrompt> {
  bool _checking = false;
  bool _needsExemption = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (!mounted) return;
    setState(() => _checking = true);
    try {
      final status = await perms.Permission.ignoreBatteryOptimizations.status;
      _needsExemption = !status.isGranted;
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openBatterySettings() async {
    try {
      // First try to request the exemption programmatically
      final req = await perms.Permission.ignoreBatteryOptimizations.request();
      if (req.isGranted) {
        setState(() => _needsExemption = false);
        return;
      }
      // Fallback: open app settings for manual configuration
      await perms.openAppSettings();
    } catch (_) {
      await perms.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_needsExemption) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            'To ensure alerts work reliably, disable battery optimizations for AquaCare.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _openBatterySettings,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              'Allow background notifications',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
