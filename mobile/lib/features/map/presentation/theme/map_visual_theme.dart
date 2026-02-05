import 'package:flutter/material.dart';

/// Visual theme for the custom painted map.
class MapVisualTheme {
  final Color oceanColor;
  final Color coastlineColor;
  final double coastlineWidth;

  final Color provinceBorderColor;
  final double provinceBorderWidth;
  final Color selectedProvinceBorderColor;
  final double selectedProvinceBorderWidth;

  final Color districtBorderColor;
  final double districtBorderWidth;
  final Color selectedDistrictBorderColor;
  final double selectedDistrictBorderWidth;

  final TextStyle labelStyle;

  /// Optional region fill overrides by region id.
  final Map<String, Color> regionFillOverrides;

  const MapVisualTheme({
    this.oceanColor = const Color(0xFF1A5F7A),
    this.coastlineColor = const Color(0x4DFFFFFF),
    this.coastlineWidth = 1.5,
    this.provinceBorderColor = const Color(0xB3FFFFFF),
    this.provinceBorderWidth = 2,
    this.selectedProvinceBorderColor = const Color(0xE6FFFFFF),
    this.selectedProvinceBorderWidth = 2.5,
    this.districtBorderColor = const Color(0x66FFFFFF),
    this.districtBorderWidth = 1,
    this.selectedDistrictBorderColor = const Color(0xFFFFD54F),
    this.selectedDistrictBorderWidth = 3,
    this.labelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black87),
      ],
    ),
    this.regionFillOverrides = const <String, Color>{},
  });

  Color resolveRegionFill(String regionId, Color fallback) {
    return regionFillOverrides[regionId] ?? fallback;
  }
}
