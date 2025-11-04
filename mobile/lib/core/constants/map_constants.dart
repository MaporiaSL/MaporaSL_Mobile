import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapConstants {
  static final sriLankaCenter = Point(coordinates: Position(80.7718, 7.8731));

  static final sriLankaBounds = CoordinateBounds(
    southwest: Point(coordinates: Position(79.65, 5.92)), // bottom-left
    northeast: Point(coordinates: Position(81.89, 9.83)), // top-right
    infiniteBounds: false,
  );
}
