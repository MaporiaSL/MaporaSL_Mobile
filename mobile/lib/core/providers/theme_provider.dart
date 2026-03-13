import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('light') {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('mapTheme');
      if (savedTheme == 'dark') {
        state = 'dark';
      } else if (savedTheme == 'light') {
        state = 'light';
      } else {
        state = 'light';
        // Clean up invalid/removed prefs silently
        prefs.setString('mapTheme', 'light');
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> setTheme(String theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mapTheme', theme);
    } catch (e) {
      // Ignored
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});
