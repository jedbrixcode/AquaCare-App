import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('theme_mode');
    if (stored == 'light') state = ThemeMode.light;
    if (stored == 'dark') state = ThemeMode.dark;
    if (stored == 'system') state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
  }
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((
  ref,
) {
  return ThemeController();
});
