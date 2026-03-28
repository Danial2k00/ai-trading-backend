import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

Future<void> hydrateThemeMode(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final v = prefs.getString(_kThemeKey);
  if (v == 'dark') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
  } else if (v == 'light') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.light;
  } else if (v == 'system') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.system;
  }
}

Future<void> persistThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kThemeKey,
    mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system',
  );
}
