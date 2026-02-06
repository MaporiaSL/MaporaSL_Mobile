import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String _apiBaseUrlFallback = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const String _authBypassFallback = String.fromEnvironment(
    'AUTH_BYPASS',
    defaultValue: 'false',
  );

  static String? _readEnv(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  // Set via .env (API_BASE_URL) or: flutter run --dart-define=API_BASE_URL=...
  static String get apiBaseUrl =>
      _readEnv('API_BASE_URL')?.trim().isNotEmpty == true
        ? _readEnv('API_BASE_URL')!.trim()
        : _apiBaseUrlFallback;

  // Set via .env (AUTH_BYPASS=true) or: flutter run --dart-define=AUTH_BYPASS=true
  static bool get authBypass {
    return true;
  }
}
