import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// The base URL for the API.
  /// Uses --dart-define=API_BASE_URL and defaults to the Android Emulator local IP.
  static String get apiBaseUrl {
    final url = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5000',
    );
    debugPrint('>>> [APP CONFIG] ACTIVE API BASE URL: $url');
    return url;
  }
}
