import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((
  ref,
) {
  return ThemeController();
});
