class AppConfig {
  AppConfig._();

  // Set via: flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://octopus-app-5vwus.ondigitalocean.app/',
  );

  // AUTH_BYPASS_ANCHOR: set to false to re-enable auth.
  static const bool authBypass = false;
}
