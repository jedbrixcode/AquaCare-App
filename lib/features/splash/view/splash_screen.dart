import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Initialization failed: $err"),
              backgroundColor: Colors.red,
            ),
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
      body: state.when(
        // LOADING UI
        loading:
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Center(
                  child: Text(
                    "Welcome to AquaCare",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                LoadingAnimationWidget.waveDots(color: Colors.white, size: 40),
                const SizedBox(height: 50),
              ],
            ),

        // ERROR UI + Retry
        error:
            (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load: $e",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(splashViewModelProvider.notifier)
                          .initializeApp();
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),

        // Once done → navigation handled in ref.listenManual
        data: (_) => const SizedBox.shrink(),
      ),
    );
  }
}
