/// Map styling and theme utilities
class MapStyleManager {
  // Color palette
  static const String primaryColor = '#7c3aed'; // Violet
  static const String successColor = '#10b981'; // Green (visited)
  static const String dangerColor = '#ef4444'; // Red (unvisited)
  static const String warningColor = '#f59e0b'; // Amber
  static const String infoColor = '#3b82f6'; // Blue
  
  // Neutral colors
  static const String textDark = '#1f2937'; // Gray 800
  static const String textLight = '#f3f4f6'; // Gray 100
  static const String borderColor = '#e5e7eb'; // Gray 200
  
  // Marker colors
  static const String markerVisited = successColor;
  static const String markerUnvisited = dangerColor;
  static const String markerActive = primaryColor;
  
  // Line colors
  static const String routeColor = primaryColor;
  static const String boundaryColor = primaryColor;
  
  // Fill colors (with transparency)
  static const String boundaryFill = '#8b5cf6'; // Light violet
  static const double boundaryOpacity = 0.1;
  
  // Line widths
  static const double routeLineWidth = 3.0;
  static const double boundaryLineWidth = 2.0;
  
  // Icon sizes
  static const double markerSize = 1.5;
  static const double textSize = 12.0;
  
  /// Get marker color based on visited status
  static String getMarkerColor(bool visited) {
    return visited ? markerVisited : markerUnvisited;
  }
  
  /// Get route style
  static Map<String, dynamic> getRouteStyle() {
    return {
      'color': routeColor,
      'width': routeLineWidth,
      'opacity': 1.0,
      'cap': 'round',
      'join': 'round',
    };
  }
  
  /// Get boundary style
  static Map<String, dynamic> getBoundaryStyle() {
    return {
      'color': boundaryColor,
      'fillColor': boundaryFill,
      'fillOpacity': boundaryOpacity,
      'lineWidth': boundaryLineWidth,
    };
  }
  
  /// Get marker style
  static Map<String, dynamic> getMarkerStyle(bool visited) {
    return {
      'color': getMarkerColor(visited),
      'size': markerSize,
      'opacity': 1.0,
      'icon': visited ? 'marker-15' : 'marker-15',
    };
  }
  
  /// Get text style for labels
  static Map<String, dynamic> getTextStyle() {
    return {
      'color': textDark,
      'size': textSize,
      'font': 'Open Sans Regular',
      'offsetY': 20.0,
      'anchor': 'top',
    };
  }
}

/// Camera position presets
class CameraPresets {
  // Sri Lanka center
  static const String sriLankaCenterLat = '7.8731';
  static const String sriLankaCenterLng = '80.7718';
  static const double sriLankaZoom = 7.0;
  
  // Bounds
  static const double sriLankaMinLat = 5.88;
  static const double sriLankaMaxLat = 9.83;
  static const double sriLankaMinLng = 79.65;
  static const double sriLankaMaxLng = 81.87;
  
  /// Get default camera position
  static Map<String, dynamic> getDefaultPosition() {
    return {
      'lat': double.parse(sriLankaCenterLat),
      'lng': double.parse(sriLankaCenterLng),
      'zoom': sriLankaZoom,
    };
  }
  
  /// Check if coordinates are within Sri Lanka
  static bool isWithinSriLanka(double lat, double lng) {
    return lat >= sriLankaMinLat &&
        lat <= sriLankaMaxLat &&
        lng >= sriLankaMinLng &&
        lng <= sriLankaMaxLng;
  }
}

/// Map interaction settings
class MapInteractionSettings {
  static const bool enableRotation = true;
  static const bool enableTilt = true;
  static const bool enableScroll = true;
  static const bool enableZoom = true;
  static const double minZoom = 4.0;
  static const double maxZoom = 18.0;
  
  /// Get interaction configuration
  static Map<String, dynamic> getConfig() {
    return {
      'rotation': enableRotation,
      'tilt': enableTilt,
      'scroll': enableScroll,
      'zoom': enableZoom,
      'minZoom': minZoom,
      'maxZoom': maxZoom,
    };
  }
}

/// Geospatial calculation utilities
class GeoUtils {
  /// Calculate distance between two points in kilometers (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    
    final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_toRad(lat1)) *
            Math.cos(_toRad(lat2)) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2);
    
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }
  
  /// Get bearing from point1 to point2 in degrees
  static double calculateBearing(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLng = _toRad(lng2 - lng1);
    final y = Math.sin(dLng) * Math.cos(_toRad(lat2));
    final x = Math.cos(_toRad(lat1)) * Math.sin(_toRad(lat2)) -
        Math.sin(_toRad(lat1)) *
            Math.cos(_toRad(lat2)) *
            Math.cos(dLng);
    
    final bearing = _toDeg(Math.atan2(y, x));
    return (bearing + 360) % 360; // Normalize to 0-360
  }
  
  /// Get cardinal direction from bearing
  static String getBearingDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
  
  /// Convert degrees to radians
  static double _toRad(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
  
  /// Convert radians to degrees
  static double _toDeg(double radians) {
    return radians * (180.0 / 3.14159265359);
  }
}

/// Import dart:math for Math functions
import 'dart:math' as Math;
