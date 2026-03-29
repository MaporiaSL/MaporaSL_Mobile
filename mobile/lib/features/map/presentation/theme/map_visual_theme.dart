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
  final Color selectedDistrictGlassTint;
  final Color selectedDistrictGlowColor;

  final Set<String> lockedDistrictIds;
  final TextStyle labelStyle;

  /// Optional region fill overrides by region id.
  final Map<String, Color> regionFillOverrides;

  bool get isDark => backgroundColor.computeLuminance() < 0.5;

  const MapVisualTheme({
    this.backgroundColor = const Color(0xFFF1F5F9), // Cool Slate Atlas
    this.borderColor = const Color(0xFFCBD5E1), // Soft Slate Border
    this.borderWidth = 1.0,
    this.fogColor = const Color(0xFFFFFFFF), // Pure White Fog (Clouds)
    this.fogOpacity = 0.8,
    // Discovery / Fog Clearing colors
    this.unlockedColor = const Color(0xFFF59E0B), // Radiant Gold - 100%
    this.nearCompleteColor = const Color(0xFF0EA5E9), // Sky Blue - Progress Inner Glow
    this.halfwayColor = const Color(0xFF38BDF8), // Sky/Azure
    this.quarterColor = const Color(0xFF94A3B8), // Muted Slate
    this.lockedColor = const Color(0xFFCBD5E1), // Soft Slate Monolith - Locked (0%)
    this.selectedDistrictBorderColor = const Color(0xFFF59E0B), // Gold match
    this.selectedDistrictBorderWidth = 2.0,
    this.selectedDistrictGlassTint = const Color(0xFFCBD5E1),
    this.selectedDistrictGlowColor = const Color(0xFFFDE68A),
    this.lockedDistrictIds = const <String>{},
    this.labelStyle = const TextStyle(
      color: Color(0xFF334155), // Dark Slate for readability
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
    this.regionFillOverrides = const <String, Color>{},
  });

  factory MapVisualTheme.dark() {
    return const MapVisualTheme(
      backgroundColor: Color(0xFF030712), // Deeper Midnight Ocean
      borderColor: Color(0xFF334155), // Refined Slate Border
      fogColor: Color(0xFF0F172A),
      fogOpacity: 0.9,
      unlockedColor: Color(0xFFF59E0B),
      nearCompleteColor: Color(0xFF22D3EE),
      halfwayColor: Color(0xFF38BDF8),
      quarterColor: Color(0xFF475569),
      lockedColor: Color(0xFF1E293B), // Higher Contrast Land (Slate)
      selectedDistrictGlassTint: Color(0xFF0F172A),
      selectedDistrictGlowColor: Color(0xFFF59E0B),
      labelStyle: TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

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
