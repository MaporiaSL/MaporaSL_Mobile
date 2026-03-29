# Windows Scripts

Windows-specific helper scripts are centralized here.

## Scripts

- run_dev_bypass_all.bat
  - Starts backend and mobile in bypass flow.

- backend/run_dev_bypass.bat
  - Runs backend dev server with AUTH_BYPASS=false in the current shell.

- mobile/run_dev_bypass.bat
  - Runs Flutter app with API_BASE_URL set for Android emulator loopback.

- mobile/run_get.bat
  - Runs flutter pub get.

## Usage

From repository root:

- scripts\windows\run_dev_bypass_all.bat
- scripts\windows\backend\run_dev_bypass.bat
- scripts\windows\mobile\run_dev_bypass.bat
- scripts\windows\mobile\run_get.bat
