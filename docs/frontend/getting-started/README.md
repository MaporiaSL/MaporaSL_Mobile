# Frontend - Getting Started

**New to Flutter? Start here!**

---

## 📚 Quick Links

- [Quick Setup](#quick-setup-10-minutes) - Get app running
- [Project Structure](project-structure.md) - Understand the codebase
- [Back to Frontend Overview](../README.md) - Full frontend documentation

---

## Quick Setup (10 minutes)

### 1. Prerequisites

- **Flutter** v3.x+ installed (`flutter --version`)
- **Dart** (comes with Flutter)
- **Android Studio** OR **Xcode** (for emulator)
- **Text Editor** (VS Code with Flutter plugin recommended)

### 2. Install Flutter

If not installed:
```bash
# macOS/Linux: https://flutter.dev/docs/get-started/install
# Windows: https://flutter.dev/docs/get-started/install/windows

flutter --version  # Verify installation
```

### 3. Get Dependencies

```bash
cd mobile
flutter pub get
```

### 4. Configure Environment

Create `.env` or add to `pubspec.yaml`:

```yaml
# In pubspec.yaml, add under flutter:
environment:
  API_BASE_URL: http://localhost:5000/api
  MAPBOX_ACCESS_TOKEN: your_token_here
  FIREBASE_PROJECT_ID: your_project_id
```

See [Environment Variables](../../common/setup-guides/environment-variables.md) for details.

### 5. Start the App

**Android Emulator**:
```bash
flutter emulators
flutter run
```

**iOS Simulator** (macOS only):
```bash
open -a Simulator
flutter run
```

**Physical Device**:
```bash
# Connect device via USB
flutter run
```

**Expected output**:
```
✓ Built build/app/outputs/apk/debug/app-debug.apk
Launching lib/main.dart on Android...
```

### 6. Verify Setup

Once app launches:
- See MAPORIA home screen
- Tap around to verify no crashes
- Check console for errors

✅ **Done!** App is running.

---

## 🎯 Next Steps

### Read Project Structure
→ [Project Structure](project-structure.md)

### Start Implementing a Feature
1. Go to [Feature Implementation](../feature-implementation/)
2. Pick a feature
3. Follow the step-by-step guide

### Understand State Management
→ [Riverpod Patterns](../state-management/riverpod-patterns.md)

### Design Your First Screen
→ [Screen Layouts](../ui-components/screen-layouts.md)

---

## 🚀 Development Workflow

### Starting a work session
```bash
cd mobile
flutter run    # Runs on emulator/device
```

### Making changes
1. Edit files in `mobile/lib/`
2. Use **hot reload**: Press `R` in terminal
3. Changes appear instantly
4. Check console for errors

### Hot Reload vs Hot Restart
```bash
# During flutter run:
r          # Hot reload (faster, preserves state)
R          # Hot restart (rebuilds app)
Ctrl+C     # Stop
```

### Running tests
```bash
flutter test
```

### Building release APK
```bash
flutter build apk --release
```

---

## ✅ Checklist

- [ ] Flutter installed
- [ ] Cloned the repo
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Emulator/device ready
- [ ] `flutter run` works
- [ ] App starts without errors
- [ ] Read [Project Structure](project-structure.md)

---

## ❓ Troubleshooting

### "flutter: command not found"
```bash
# Add Flutter to PATH
# See https://flutter.dev/docs/get-started/install
```

### App won't start / dependency errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Emulator won't start
```bash
# List available emulators
flutter emulators

# Create new emulator
flutter emulators --create --name "android_emulator"

# Launch it
flutter emulator --launch android_emulator
```

### Hot reload not working
```bash
# Stop app
Ctrl+C

# Restart with full rebuild
flutter run
```

### Build errors
```bash
# Clean everything
flutter clean

# Rebuild
flutter pub get
flutter run
```

---

## 📖 Full Documentation

For more details, see:
- [Project Structure](project-structure.md) - File organization
- [Frontend Overview](../README.md) - All frontend docs
- [Feature Implementation](../feature-implementation/) - Start implementing
- [State Management](../state-management/) - Riverpod patterns
- [Common Setup Guides](../../common/setup-guides/) - Environment setup

---

**Ready to code? → [Project Structure](project-structure.md)**
