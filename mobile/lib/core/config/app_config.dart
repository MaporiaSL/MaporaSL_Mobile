import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// The base URL for the API.
  /// Prioritizes .env 'API_BASE_URL' then --dart-define=API_BASE_URL, 
  /// and finally defaults to the Android Emulator local IP.
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://10.0.2.2:5000',
           );
    debugPrint('>>> [APP CONFIG] ACTIVE API BASE URL: $url');
    return url;
  }
}
