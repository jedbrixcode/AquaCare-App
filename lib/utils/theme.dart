import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/core/services/local_storage_service.dart';

/// ----------------------------
/// THEME DEFINITIONS
/// ----------------------------

final lightTheme = ThemeData.light(useMaterial3: false).copyWith(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.black87),
    displayMedium: TextStyle(color: Colors.black87),
    displaySmall: TextStyle(color: Colors.black87),
    headlineLarge: TextStyle(color: Colors.black87),
    headlineMedium: TextStyle(color: Colors.black87),
    headlineSmall: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87),
    titleMedium: TextStyle(color: Colors.black87),
    titleSmall: TextStyle(color: Colors.black87),
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black87),
    labelLarge: TextStyle(color: Colors.black87),
    labelMedium: TextStyle(color: Colors.black87),
    labelSmall: TextStyle(color: Colors.black87),
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
    secondary: Colors.blueAccent,
    background: Colors.white,
    onBackground: Colors.black87,
    surface: const Color.fromARGB(255, 65, 65, 65),
    onSurface: const Color.fromARGB(221, 36, 36, 36),
    error: Colors.red.shade700,
    onError: Colors.white,
  ),
);

final darkTheme = ThemeData.dark(useMaterial3: false).copyWith(
  scaffoldBackgroundColor: const Color(0xFF0B152B), // Dark background
  primaryColor: const Color(0xFF1E293B),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E293B),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white70),
    titleSmall: TextStyle(color: Colors.white70),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white60),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white70),
    labelSmall: TextStyle(color: Colors.white60),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 0, 50, 126),
    secondary: Color.fromARGB(255, 0, 20, 49),
    background: Color(0xFF0B152B),
    onBackground: Colors.white,
    surface: Color.fromARGB(255, 65, 65, 65),
    onSurface: Color.fromARGB(221, 36, 36, 36),
    error: Colors.redAccent,
    onError: Colors.black,
  ),
);

/// ----------------------------
/// THEME CONTROLLER + PROVIDER
/// ----------------------------
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final stored = await LocalStorageService.instance.getThemeModeString();
    if (stored == 'light') state = ThemeMode.light;
    if (stored == 'dark') state = ThemeMode.dark;
    if (stored == 'system') state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value =
        mode == ThemeMode.light
            ? 'light'
            : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await LocalStorageService.instance.setThemeModeString(value);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((
  ref,
) {
  return ThemeController();
});
