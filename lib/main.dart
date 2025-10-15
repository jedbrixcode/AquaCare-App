import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/view/splash_screen.dart';
import 'core/services/local_storage_service.dart';
import 'core/navigation/route_observer.dart';
import 'utils/theme.dart';
import 'features/chat/view/chat_with_ai_page.dart';
import 'features/graphs/view/sensor_graphs_page.dart';
import 'features/settings/view/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaCare',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
      navigatorObservers: [appRouteObserver],
      home: const SplashScreen(),
      routes: {
        '/chat': (context) => const AIChatPage(),
        '/graphs': (context) => const SensorGraphsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
