import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/map_constants.dart';

class MapboxMapScreen extends StatefulWidget {
  const MapboxMapScreen({super.key});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MAPORIA')),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(80.7718, 7.8731),
          ), // Center of Sri Lanka
          zoom: 6.5,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('mapTheme') ?? 'default';

    String styleUrl = MapConstants.gameStyleUrl;
    if (theme == 'dark') {
      styleUrl = MapConstants.darkStyleUrl;
    } else if (theme == 'cartoon') {
      styleUrl = MapConstants.cartoonStyleUrl;
    }

    mapboxMap.loadStyleURI(styleUrl);
  }
}
