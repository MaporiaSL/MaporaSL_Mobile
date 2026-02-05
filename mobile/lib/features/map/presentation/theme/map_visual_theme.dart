import 'package:flutter/material.dart';

/// Visual theme for the custom painted map.
class MapVisualTheme {
  final Color oceanColor;
  final Color coastlineColor;
  final double coastlineWidth;
  final Color oceanGlowColor;
  final double oceanGlowWidth;

  final Color provinceBorderColor;
  final double provinceBorderWidth;
  final Color selectedProvinceBorderColor;
  final double selectedProvinceBorderWidth;

  final Color districtBorderColor;
  final double districtBorderWidth;
  final Color selectedDistrictBorderColor;
  final double selectedDistrictBorderWidth;
  final Color runeGlowColor;
  final double runeGlowBlur;

  final Color extrusionSideColor;
  final double extrusionDepth;
  final Offset shadowOffset;
  final double shadowBlur;
  final Color rimLightColor;
  final double rimLightWidth;

  final LinearGradient unlockedGradient;
  final LinearGradient fogGradient;
  final double fogOpacity;
  final Color fogShadowColor;
  final double fogShadowBlur;
  final Set<String> lockedDistrictIds;

  final TextStyle labelStyle;

  /// Optional region fill overrides by region id.
  final Map<String, Color> regionFillOverrides;

  const MapVisualTheme({
    this.oceanColor = const Color(0xFF1A5F7A),
    this.coastlineColor = const Color(0x4DFFFFFF),
    this.coastlineWidth = 1.5,
    this.oceanGlowColor = const Color(0x994FFBFF),
    this.oceanGlowWidth = 3,
    this.provinceBorderColor = const Color(0xB3FFFFFF),
    this.provinceBorderWidth = 2,
    this.selectedProvinceBorderColor = const Color(0xE6FFFFFF),
    this.selectedProvinceBorderWidth = 2.5,
    this.districtBorderColor = const Color(0x66FFFFFF),
    this.districtBorderWidth = 1,
    this.selectedDistrictBorderColor = const Color(0xFFFFD54F),
    this.selectedDistrictBorderWidth = 3,
    this.runeGlowColor = const Color(0xFF5CFFFA),
    this.runeGlowBlur = 6,
    this.extrusionSideColor = const Color(0xFF1E1A16),
    this.extrusionDepth = 10,
    this.shadowOffset = const Offset(18, 24),
    this.shadowBlur = 18,
    this.rimLightColor = const Color(0xCCFFFFFF),
    this.rimLightWidth = 2,
    this.unlockedGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF16C172), Color(0xFFFFE066), Color(0xFFB86B3E)],
    ),
    this.fogGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE8F2FF), Color(0xFF22314F), Color(0xFF0B1224)],
    ),
    this.fogOpacity = 0.85,
    this.fogShadowColor = const Color(0x55000000),
    this.fogShadowBlur = 12,
    this.lockedDistrictIds = const <String>{},
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
