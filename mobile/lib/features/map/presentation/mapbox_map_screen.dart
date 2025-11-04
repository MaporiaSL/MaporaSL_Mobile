import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../core/constants/map_constants.dart';

class MapboxMapScreen extends StatefulWidget {
  const MapboxMapScreen({super.key});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  MapboxMap? _mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: MapConstants.sriLankaCenter,
          zoom: 7.5,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // ✅ Load the standard Mapbox Streets style
    await _mapboxMap!.loadStyleURI("mapbox://styles/mapbox/streets-v12");

    // ✅ Configure allowed gestures (valid for 2.12.0)
    await _mapboxMap!.gestures.updateSettings(GesturesSettings(
      rotateEnabled: false,
      pitchEnabled: false,
      scrollEnabled: true,
      pinchToZoomEnabled: true,  // ✅ allows pinch zoom
      quickZoomEnabled: true,    // ✅ enables quick zoom gesture
      doubleTapToZoomInEnabled: true, // ✅ double-tap zoom in only
      simultaneousRotateAndPinchToZoomEnabled: false,
    ));

    // ✅ Restrict the map camera to Sri Lanka region
    await _mapboxMap!.setBounds(
      CameraBoundsOptions(
        bounds: MapConstants.sriLankaBounds,
        maxZoom: 12,
        minZoom: 6,
      ),
    );
  }
}
