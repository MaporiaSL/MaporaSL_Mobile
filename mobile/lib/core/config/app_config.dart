class AppConfig {
  AppConfig._();

  // Set via: flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  // Enable only for local development when explicitly provided:
  // flutter run --dart-define=AUTH_BYPASS=true
  static const bool authBypass = bool.fromEnvironment(
    'AUTH_BYPASS',
    defaultValue: false,
  );

  // Optional development fallback UID when auth bypass is enabled.
  static const String profileFallbackUserId = String.fromEnvironment(
    'PROFILE_FALLBACK_USER_ID',
    defaultValue: 'test-user-123',
  );
}
