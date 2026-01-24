import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/map/presentation/game_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mapbox access token
  MapboxOptions.setAccessToken(
    "pk.eyJ1IjoiYW51amEtaiIsImEiOiJjbWhrazJoZHIxMG9rMmpvOGVzNTJwem9oIn0.QjUIU6cABQ1NjmwHdbNnsQ",
  );

  runApp(const ProviderScope(child: MaporiaApp()));
}

class MaporiaApp extends StatelessWidget {
  const MaporiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAPORIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const GameMapScreen(),
    );
  }
}
