import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class MapConstants {
  // Mapbox Style - Custom "Game" aesthetic
  // Format: mapbox://styles/YOUR_USERNAME/YOUR_STYLE_ID
  static const String gameStyleUrl = 'mapbox://styles/mapbox/outdoors-v12';

  // Mapbox Access Tokens
  static const String publicAccessToken = String.fromEnvironment(
    'MAPBOX_PUBLIC_TOKEN',
    defaultValue: 'pk.YOUR_PUBLIC_TOKEN_HERE',
  );

  static const String secretAccessToken = String.fromEnvironment(
    'MAPBOX_SECRET_TOKEN',
    defaultValue: 'sk.YOUR_SECRET_TOKEN_HERE',
  );

  // Sri Lanka geographic center
  static final sriLankaCenter = mapbox.Point(
    coordinates: mapbox.Position(80.7718, 7.8731),
  );

  // Sri Lanka bounding box
  static final sriLankaBounds = mapbox.CoordinateBounds(
    southwest: mapbox.Point(coordinates: mapbox.Position(79.65, 5.92)),
    northeast: mapbox.Point(coordinates: mapbox.Position(81.89, 9.83)),
    infiniteBounds: false,
  );

  // Map zoom levels
  static const double defaultZoom = 6.5;
  static const double minZoom = 6.0;
  static const double maxZoom = 18.0;
  static const double districtZoom = 9.0;
  static const double placeZoom = 14.0;

  // Marker colors
  static const int visitedMarkerColor = 0xFF10B981; // Green
  static const int unvisitedMarkerColor = 0xFF3B82F6; // Red/Blue

  // GPS verification
  static const double visitRadiusMeters = 100.0;

  // Fog layer
  static const double fogOpacity = 0.6;
  static const int fogColor = 0x99000000; // Dark grey with transparency
}
