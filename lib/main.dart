import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/settings/viewmodel/theme_viewmodel.dart';
import 'core/navigation/route_observer.dart';
import 'features/chat/view/chat_with_ai_page.dart';
import 'features/graphs/view/sensor_graphs_page.dart';
import 'features/settings/view/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaCare',
      theme: ThemeData.light(useMaterial3: false).copyWith(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      darkTheme: ThemeData.dark(useMaterial3: false),
      themeMode: themeMode,
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
