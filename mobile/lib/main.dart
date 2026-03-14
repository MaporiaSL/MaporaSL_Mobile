import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/accessibility_provider.dart';
import 'core/providers/security_provider.dart';
import 'splash/presentation/splash_screen.dart';
import 'features/auth/presentation/app_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Load environment variables from root directory
  try {
    await dotenv.load(fileName: "../.env");
  } catch (e) {
    // .env file is optional
    debugPrint('Note: .env file not found, using default config');
  }

  // Initialize Mapbox access token
  MapboxOptions.setAccessToken(
    "pk.eyJ1IjoiYW51amEtaiIsImEiOiJjbWhrazJoZHIxMG9rMmpvOGVzNTJwem9oIn0.QjUIU6cABQ1NjmwHdbNnsQ",
  );

  runApp(const ProviderScope(child: MaporiaApp()));
}

class MaporiaApp extends ConsumerWidget {
  const MaporiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeStr = ref.watch(themeProvider);
    final themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    final accessibility = ref.watch(accessibilityProvider);

    return MaterialApp(
      title: 'MAPORIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(highContrast: accessibility.highContrast),
      darkTheme: AppTheme.dark(highContrast: accessibility.highContrast),
      themeMode: themeMode,
      builder: (context, child) {
        return SecurityWrapper(
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(accessibility.fontSize)),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

class SecurityWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SecurityWrapper({super.key, required this.child});

  @override
  ConsumerState<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends ConsumerState<SecurityWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final prefs = await SharedPreferences.getInstance();
    final isAppLockEnabled =
        prefs.getBool('security_app_lock_enabled') ?? false;
    if (isAppLockEnabled && mounted) {
      setState(() => _isLocked = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final security = ref.read(securityProvider);
      if (security.isAppLockEnabled) {
        setState(() => _isLocked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Stack(
        children: [
          widget.child,
          AppLockScreen(onUnlock: () => setState(() => _isLocked = false)),
        ],
      );
    }
    return widget.child;
  }
}
