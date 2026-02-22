import 'package:flutter/material.dart';

/// Visual theme for the custom painted map.
class MapVisualTheme {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color fogColor;
  final double fogOpacity;

  // Progressive unlock colors
  final Color unlockedColor; // 100% - Gold
  final Color nearCompleteColor; // 75%+ - Light gold
  final Color halfwayColor; // 50%+ - Light teal
  final Color quarterColor; // 25%+ - Light slate
  final Color lockedColor; // < 25% - Very light grey

  final Color selectedDistrictBorderColor;
  final double selectedDistrictBorderWidth;

  final Set<String> lockedDistrictIds;
  final TextStyle labelStyle;

  /// Optional region fill overrides by region id.
  final Map<String, Color> regionFillOverrides;

  const MapVisualTheme({
    this.backgroundColor = const Color(0xFFFAFAFA), // White
    this.borderColor = const Color(0xFF00A6B2), // Teal
    this.borderWidth = 1.5,
    this.fogColor = const Color(0xFFE8F4F8), // Light foggy blue
    this.fogOpacity = 0.4,
    // Progressive unlock colors
    this.unlockedColor = const Color(0xFFD4AF37), // Gold - 100%
    this.nearCompleteColor = const Color(0xFFE6C75B), // Light gold - 75%+
    this.halfwayColor = const Color(0xFF4FD1D9), // Light teal - 50%+
    this.quarterColor = const Color(0xFFC5D9E8), // Light slate - 25%+
    this.lockedColor = const Color(0xFFE8EAED), // Very light grey - <25%
    this.selectedDistrictBorderColor = const Color(0xFF00A6B2), // Teal
    this.selectedDistrictBorderWidth = 2.5,
    this.lockedDistrictIds = const <String>{},
    this.labelStyle = const TextStyle(
      color: Color(0xFF1F6F8B), // Cool slate
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(offset: Offset(1, 1), blurRadius: 1, color: Color(0xFFFFFFFF)),
      ],
    ),
    this.regionFillOverrides = const <String, Color>{},
  });

  Color resolveRegionFill(String regionId, Color fallback) {
    return regionFillOverrides[regionId] ?? fallback;
  }

  /// Returns the fill color for a district based on completion percentage (0.0-1.0).
  /// - 1.0 (100%) → Gold
  /// - 0.75-0.99 (75%+) → Light gold
  /// - 0.5-0.74 (50%+) → Light teal
  /// - 0.25-0.49 (25%+) → Light slate
  /// - <0.25 → Very light grey (locked)
  Color getDistrictProgressColor(double progressPercentage) {
    if (progressPercentage >= 1.0) {
      return unlockedColor; // Gold - 100%
    } else if (progressPercentage >= 0.75) {
      return nearCompleteColor; // Light gold - 75%+
    } else if (progressPercentage >= 0.5) {
      return halfwayColor; // Light teal - 50%+
    } else if (progressPercentage > 0) {
      return quarterColor; // Light slate - 25%+
    } else {
      return lockedColor; // Very light grey - <25%
    }
  }
}
