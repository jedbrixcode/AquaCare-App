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
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(secondary: Colors.blueAccent),
);

final darkTheme = ThemeData.dark(useMaterial3: false).copyWith(
  scaffoldBackgroundColor: const Color.fromARGB(255, 11, 21, 43),
  primaryColor: const Color(0xFF1E293B),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E293B),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Colors.cyanAccent,
    secondary: Colors.tealAccent,
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
