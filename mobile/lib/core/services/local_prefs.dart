import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for auth-related local data.
class LocalPrefs {
  static const _keyHometownDistrict = 'pending_hometown_district';

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
}
