class AppConfig {
  AppConfig._();

  // Set via: flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  // AUTH_BYPASS_ANCHOR: set to false to re-enable auth.
  static const bool authBypass = true;
=======
  // Temporary local-dev bypass. Set false (or pass --dart-define=AUTH_BYPASS=false)
  // to restore login flow.
=======
  // AUTH_BYPASS_ANCHOR: override with --dart-define=AUTH_BYPASS=false.
>>>>>>> Stashed changes
  static const bool authBypass = bool.fromEnvironment(
    'AUTH_BYPASS',
    defaultValue: true,
  );
<<<<<<< Updated upstream

  // Optional development fallback UID when auth bypass is enabled.
  static const String profileFallbackUserId = String.fromEnvironment(
    'PROFILE_FALLBACK_USER_ID',
    defaultValue: 'test-user-123',
  );
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
}
