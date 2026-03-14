@echo off
setlocal
flutter run --dart-define=AUTH_BYPASS=true --dart-define=PROFILE_FALLBACK_USER_ID=test-user-123 --dart-define=API_BASE_URL=http://10.0.2.2:5000
endlocal
