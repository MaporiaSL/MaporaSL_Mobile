import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Thin wrapper around SharedPreferences for auth-related local data.
class LocalPrefs {
  static const _keyHometownDistrict = 'pending_hometown_district';
  static const _keyProfileSetupDraft = 'profile_setup_draft';
  static const _keyProfileSetupCompleted = 'profile_setup_completed';

  /// Persist the district chosen during sign-up so it survives app restarts
  /// (needed when the user hasn't verified their email yet).
  static Future<void> saveHometownDistrict(String district) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHometownDistrict, district);
  }

  /// Retrieve the locally-stored hometown district.
  /// Returns `null` if nothing was saved.
  static Future<String?> getHometownDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHometownDistrict);
  }

  /// Remove the cached district (call after successful backend registration).
  static Future<void> clearHometownDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHometownDistrict);
  }

  static Future<void> saveProfileSetupDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileSetupDraft, jsonEncode(draft));
  }

  static Future<Map<String, dynamic>?> getProfileSetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfileSetupDraft);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearProfileSetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfileSetupDraft);
  }

  static Future<void> markProfileSetupCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProfileSetupCompleted, completed);
  }

  static Future<bool> isProfileSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileSetupCompleted) ?? false;
  }
}
