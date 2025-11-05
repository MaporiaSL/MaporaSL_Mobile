import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../core/constants/map_constants.dart';
import '../../../core/services/permission_service.dart';
import 'package:geolocator/geolocator.dart';

class MapboxMapScreen extends StatefulWidget {
  const MapboxMapScreen({super.key});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  mapbox.MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final granted = await PermissionService.requestLocationPermissions();
    if (!granted) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (_mapboxMap != null) {
      await _mapboxMap!.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(position.longitude, position.latitude),
          ),
          zoom: 1.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mapbox.MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: mapbox.CameraOptions(
          center: MapConstants.sriLankaCenter,
          zoom: 7.5,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.loadStyleURI("mapbox://styles/anuja-j/cmhlo2u6k004p01sjgqr60he9");

    await _mapboxMap!.gestures.updateSettings(mapbox.GesturesSettings(
      rotateEnabled: false,
      pitchEnabled: false,
      scrollEnabled: true,
      pinchToZoomEnabled: true,
      quickZoomEnabled: true,
      doubleTapToZoomInEnabled: true,
    ));

    await _mapboxMap!.setBounds(
      mapbox.CameraBoundsOptions(
        bounds: MapConstants.sriLankaBounds,
        maxZoom: 16,
        minZoom: 6,
      ),
    );

    await _mapboxMap!.location.updateSettings(mapbox.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ));

    await _initializeLocation();
  }
}
