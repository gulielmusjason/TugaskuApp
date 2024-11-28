import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal() {
    _loadSavedTheme();
  }

  final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeNotifier.value = ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> toggleTheme() async {
    ThemeMode newMode;
    switch (_themeNotifier.value) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }
    await setThemeMode(newMode);
  }

  bool get isDarkMode {
    if (_themeNotifier.value == ThemeMode.system) {
      // Cek tema sistem
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeNotifier.value == ThemeMode.dark;
  }

  ThemeMode get currentThemeMode => _themeNotifier.value;
}
