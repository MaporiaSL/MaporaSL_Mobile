import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/permission_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/map/presentation/map_screen.dart';

void main() {
  runApp(const ProviderScope(child: GemifiedTravelApp())); // ✅ Wrap app here
}

class GemifiedTravelApp extends StatelessWidget {
  const GemifiedTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAPORIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const ThemeTestScreen(),
    );
  }
}

class ThemeTestScreen extends StatelessWidget {
  const ThemeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello Explorer!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final granted =
                    await PermissionService.requestLocationPermissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(granted
                        ? '✅ Location permission granted!'
                        : '❌ Location permission denied.'),
                  ),
                );
              },
              child: const Text('Test Location Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
