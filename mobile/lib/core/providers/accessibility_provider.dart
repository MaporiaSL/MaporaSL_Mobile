import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettings {
  final double fontSize;
  final bool highContrast;
  final bool reduceMotion;

  const AccessibilitySettings({
    this.fontSize = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
  });

  bool get useAnimations => !reduceMotion;

  AccessibilitySettings copyWith({
    double? fontSize,
    bool? highContrast,
    bool? reduceMotion,
  }) {
    return AccessibilitySettings(
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(const AccessibilitySettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AccessibilitySettings(
        fontSize: prefs.getDouble('fontSize') ?? 1.0,
        highContrast: prefs.getBool('highContrast') ?? false,
        reduceMotion: prefs.getBool('reduceMotion') ?? false,
      );
    } catch (e) {
      // Ignored
    }
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
  return AccessibilityNotifier();
});
