import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../data/regions_data.dart';
import '../theme/map_visual_theme.dart';
import '../../providers/user_location_provider.dart';

/// Cartoonish painter for rendering stylized Sri Lanka map with GeoJSON boundaries
/// Renders actual province and district outlines with progressive unlock colors
class CartoonMapPainter extends CustomPainter {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final Map<String, List<Path>> provincePaths;
  final Map<String, List<Path>> districtPaths;
  final Map<String, Offset> provinceLabelPositions;
  final String? selectedDistrictName;
  final bool focusMode;
  final String? focusedDistrictName;
  final MapVisualTheme theme;

  /// Map of district ID to completion percentage (0.0 - 1.0)
  final Map<String, double> districtProgress;

  /// User's current location to display on map
  final UserLocation? userLocation;

  CartoonMapPainter({
    required this.regions,
    this.selectedRegionId,
    required this.provincePaths,
    required this.districtPaths,
    required this.provinceLabelPositions,
    this.selectedDistrictName,
    this.focusMode = false,
    this.focusedDistrictName,
    required this.theme,
    this.districtProgress = const <String, double>{},
    this.userLocation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      // Safety: Validate size
      if (size.width <= 0 || size.height <= 0) {
        debugPrint('❌ Map Polish: Invalid canvas size: $size');
        return;
      }

      // 1. Draw base background (Water/Empty space)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
        Paint()..color = theme.backgroundColor,
      );

      // Draw a subtle island silhouette so focused edge districts don't look like ocean-only views.
      final islandSilhouette = Path();
      for (final district in districtPaths.values) {
        for (final path in district) {
          islandSilhouette.addPath(path, Offset.zero);
        }
      }
      canvas.drawPath(
        islandSilhouette,
        Paint()..color = theme.lockedColor.withValues(alpha: 0.20),
      );

      // 2. Draw all provinces base (Subtle)
      for (final region in regions) {
        _drawProvince(canvas, size, region);
      }

      // 3. Draw district fills (Progress colors)
      _drawDistrictsFilled(canvas);

      // 4. Draw Fog of War Overlay
      _drawFogOverlay(canvas, size);

      // 5. Draw grainy texture for atmosphere
      _drawGrainOverlay(canvas, size);

      // 6. Selected district highlight (Clear of fog)
      _drawSelectedDistrictHighlight(canvas);

      // 7. Draw user location indicator
      _drawUserLocation(canvas, size);

      // 8. Draw outer border
      _drawBorders(canvas, size);
    } catch (e) {
      debugPrint('❌ Map Polish: Critical rendering error: $e');
      // Fallback: Draw a simple error background so app doesn't crash
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = theme.backgroundColor,
      );
    }
  }

  /// Draw a province with its color
  void _drawProvince(Canvas canvas, Size size, SriLankaRegion region) {
    // Find matching boundary for this region
    List<Path>? polygons;
    for (final entry in provincePaths.entries) {
      final keyLower = entry.key.toLowerCase();
      final displayLower = region.displayName.toLowerCase();

      if (keyLower.contains(displayLower) ||
          displayLower.contains(keyLower.split(' ')[0])) {
        polygons = entry.value;
        break;
      }
    }

    if (polygons == null) return;

    final borderPaint = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (final path in polygons) {
      canvas.drawPath(path, borderPaint);
    }
  }

  /// Draw all districts with progressive unlock colors and enhanced visual effects
  void _drawDistrictsFilled(Canvas canvas) {
    for (final entry in districtPaths.entries) {
      final districtId = entry.key;
      final districtPathList = entry.value;
      final isFocusedDistrict =
          focusedDistrictName != null &&
          districtId.toLowerCase() == focusedDistrictName!.toLowerCase();
      final shouldDim = focusMode && !isFocusedDistrict;

      // Get progress for this district
      final progress = districtProgress[districtId] ?? 0.0;
      final reveal = progress.clamp(0.0, 1.0);

      // District-specific base color with vibrant enhancement
      final districtBaseColor = _districtBaseColor(districtId);
      final vibranceBoost = HSLColor.fromColor(
        districtBaseColor,
      ).withSaturation(0.75).toColor();

      final targetColor =
          Color.lerp(
            vibranceBoost,
            theme.getDistrictProgressColor(progress),
            0.25,
          ) ??
          vibranceBoost;

      // Enhanced color blending
      var fillColor =
          Color.lerp(theme.lockedColor, targetColor, 0.18 + (0.82 * reveal)) ??
          theme.lockedColor;

      if (isFocusedDistrict && focusMode) {
        fillColor =
            Color.lerp(fillColor, theme.selectedDistrictGlassTint, 0.50) ??
            theme.selectedDistrictGlassTint;
      }

      final opacity = shouldDim
          ? 0.10
          : (isFocusedDistrict && focusMode
                ? 0.94
                : (progress == 0 ? 0.48 : (0.60 + (0.32 * reveal))));

      final fillPaint = Paint()
        ..color = fillColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color =
            (isFocusedDistrict && focusMode
                    ? theme.selectedDistrictBorderColor
                    : theme.borderColor)
                .withValues(
                  alpha: shouldDim
                      ? 0.05
                      : (isFocusedDistrict && focusMode
                            ? 0.50
                            : 0.12 + (0.12 * progress)),
                )
        ..strokeWidth = 0.6
        ..style = PaintingStyle.stroke;

      for (final path in districtPathList) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);

        // Add subtle inner shadow for depth on revealed districts
        if (reveal > 0.3 && !shouldDim) {
          final shadowPaint = Paint()
            ..color = Colors.black.withValues(alpha: 0.08 * reveal)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          canvas.drawPath(path, shadowPaint);
        }
      }

      // Draw labels for all districts, but opacity depends on progress
      if (!focusMode || isFocusedDistrict) {
        _drawDistrictLabelFor(canvas, districtId, districtPathList, progress);
      }
    }
  }

  Color _districtBaseColor(String districtId) {
    final hash = districtId.toLowerCase().runes.fold<int>(
      0,
      (acc, rune) => ((acc * 31) + rune) & 0x7fffffff,
    );
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.62, 0.54).toColor();
  }

  /// Calculate centroid and draw district label with enhanced visual style
  void _drawDistrictLabelFor(
    Canvas canvas,
    String districtId,
    List<Path> paths,
    double progress,
  ) {
    if (paths.isEmpty) return;

    // Simple way to get a center for the label
    final bounds = paths.first.getBounds();
    final center = bounds.center;

    // Label becomes clearer as fog clears
    final labelOpacity = (0.3 + (0.65 * progress)).clamp(0.0, 1.0);
    final labelScale = 0.9 + (0.15 * progress); // Grow as revealed

    // Draw subtle background for better readability
    final textPainter = TextPainter(
      text: TextSpan(
        text: districtId,
        style: theme.labelStyle.copyWith(
          color: Colors.white.withValues(alpha: labelOpacity),
          fontSize: 8,
          fontWeight: progress > 0.5 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw semi-transparent background for text
    final labelBgPaint = Paint()
      ..color = Colors.black.withValues(alpha: labelOpacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: textPainter.width + 4,
          height: textPainter.height + 2,
        ),
        const Radius.circular(2),
      ),
      labelBgPaint,
    );

    // Draw the text with scale
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(labelScale);
    canvas.translate(-center.dx, -center.dy);

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    canvas.restore();
  }

  /// Draw the fog overlay with enhanced visual quality
  void _drawFogOverlay(Canvas canvas, Size size) {
    if (!focusMode || focusedDistrictName == null) return;

    final paths = districtPaths[focusedDistrictName!];
    if (paths == null || paths.isEmpty) {
      debugPrint(
        '⚠️ Map Polish: No paths found for focused district: $focusedDistrictName',
      );
      return;
    }

    try {
      // Animated fog intensity for breathing effect
      final breathingIntensity =
          (math.sin(DateTime.now().millisecondsSinceEpoch / 3000.0) + 1) / 2;
      final baseAlpha = 0.50 + (0.08 * breathingIntensity);

      // Create layered fog for depth
      // Layer 1: Deep shadow layer
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: baseAlpha * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        shadowPaint,
      );

      // Layer 2: Semi-transparent colored fog (theme-aware)
      final fogColor = theme.backgroundColor.computeLuminance() > 0.5
          ? Colors.grey.shade900
          : Colors.grey.shade800;
      final fogPaint = Paint()
        ..color = fogColor.withValues(alpha: baseAlpha * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fogPaint);

      // Create a mask path for the focused district (what should be revealed)
      final maskPath = Path();
      for (final path in paths) {
        maskPath.addPath(path, Offset.zero);
      }

      // Use XOR blend mode to "cut out" the focused district from fog
      final revealPaint = Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.fill;

      canvas.drawPath(maskPath, revealPaint);

      // Add a subtle gradient edge for smooth transition
      final edgePath = Path();
      for (final path in paths) {
        edgePath.addPath(path, Offset.zero);
      }

      final edgeHighlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(edgePath, edgeHighlightPaint);
    } catch (e) {
      debugPrint('❌ Map Polish: Error rendering fog overlay: $e');
    }
  }

  /// Add an enhanced grainy/noisy procedural texture with scanlines
  void _drawGrainOverlay(Canvas canvas, Size size) {
    final isDark = theme.backgroundColor.computeLuminance() < 0.5;

    // Main grain texture
    final grainPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF334155)).withValues(
        alpha: 0.05,
      )
      ..strokeWidth = 1.0;

    final random = math.Random(42); // Seed for stability
    for (int i = 0; i < 1500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], grainPaint);
    }

    // Subtle horizontal scanlines for film effect
    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    // Vignette effect (darker edges)
    final vignetteGradient = RadialGradient(
      radius: 1.2,
      colors: [
        Colors.transparent,
        (isDark ? Colors.black : Colors.grey.shade900).withValues(alpha: 0.15),
      ],
    );

    final vignettePaint = Paint()
      ..shader = vignetteGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );
  }

  /// Highlight the selected district with enhanced visual effects
  void _drawSelectedDistrictHighlight(Canvas canvas) {
    if (selectedDistrictName == null) return;

    final paths = districtPaths[selectedDistrictName!];
    if (paths == null || paths.isEmpty) return;

    // Multi-layer glow effect for better visual feedback
    final glowLayers = [
      (radius: 8.0, alpha: 0.15),
      (radius: 5.0, alpha: 0.25),
      (radius: 2.0, alpha: 0.35),
    ];

    for (final glowLayer in glowLayers) {
      final glowPaint = Paint()
        ..color = theme.selectedDistrictGlowColor.withValues(
          alpha: glowLayer.alpha,
        )
        ..strokeWidth = 3.0
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowLayer.radius)
        ..style = PaintingStyle.stroke;

      for (final path in paths) {
        canvas.drawPath(path, glowPaint);
      }
    }

    // Bright border highlight
    final highlightPaint = Paint()
      ..color = theme.selectedDistrictBorderColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      canvas.drawPath(path, highlightPaint);
    }

    // Animated pulse effect (inner semi-transparent fill)
    final pulseOpacity =
        (math.sin(DateTime.now().millisecondsSinceEpoch / 500.0) + 1) / 3;
    final pulsePaint = Paint()
      ..color = theme.selectedDistrictGlassTint.withValues(
        alpha: 0.15 + (0.10 * pulseOpacity),
      )
      ..style = PaintingStyle.fill;

    for (final path in paths) {
      canvas.drawPath(path, pulsePaint);
    }
  }

  /// Draw user location indicator with accuracy circle and pulsing ring
  void _drawUserLocation(Canvas canvas, Size size) {
    if (userLocation == null || provincePaths.isEmpty) return;

    try {
      // For now, convert lat/lng to pixel coordinates
      // This is a simple linear approximation - can be improved with proper projection
      final canvasPoint = _latLngToPixel(
        userLocation!.latitude,
        userLocation!.longitude,
        size,
      );

      if (canvasPoint == null) return; // Outside map bounds

      const userLocationRadius = 6.0;
      final accuracy = userLocation!.accuracy ?? 30.0;
      final accuracyPixels =
          (accuracy / 111000) * size.width / 2; // Rough conversion

      // Layer 1: Accuracy circle (semi-transparent)
      final accuracyPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(canvasPoint, accuracyPixels, accuracyPaint);

      // Layer 2: Accuracy border
      final accuracyBorderPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.2)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(canvasPoint, accuracyPixels, accuracyBorderPaint);

      // Layer 3: Pulsing outer ring
      final pulseOpacity =
          (math.sin(DateTime.now().millisecondsSinceEpoch / 800.0) + 1) / 2;
      final pulseRadius = userLocationRadius + (8.0 * pulseOpacity);

      final pulsePaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.3 * (1 - pulseOpacity))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(canvasPoint, pulseRadius, pulsePaint);

      // Layer 4: Main user location dot
      final userDotPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawCircle(canvasPoint, userLocationRadius, userDotPaint);

      // Layer 5: White border for contrast
      final dotBorderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(canvasPoint, userLocationRadius, dotBorderPaint);
    } catch (e) {
      debugPrint('❌ Map Polish: Error drawing user location: $e');
    }
  }

  /// Convert latitude/longitude to canvas pixel coordinates
  Offset? _latLngToPixel(double lat, double lng, Size size) {
    // Simple bounds for Sri Lanka
    const minLat = 5.9;
    const maxLat = 7.7;
    const minLng = 80.0;
    const maxLng = 81.9;

    // Check if location is within bounds
    if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) {
      return null;
    }

    // Linear interpolation to canvas coordinates
    final x = ((lng - minLng) / (maxLng - minLng)) * size.width;
    final y = ((maxLat - lat) / (maxLat - minLat)) * size.height;

    return Offset(x, y);
  }

  /// Draw enhanced outer border with glow effect
  void _drawBorders(Canvas canvas, Size size) {
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.15)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2.0)
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      outerGlowPaint,
    );

    // Main border
    final borderPaint = Paint()
      ..color = theme.borderColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Inner highlight for depth
    final innerHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
        const Radius.circular(11),
      ),
      innerHighlightPaint,
    );
  }

  @override
  bool shouldRepaint(CartoonMapPainter oldDelegate) {
    return oldDelegate.selectedRegionId != selectedRegionId ||
        oldDelegate.regions != regions ||
        oldDelegate.provincePaths != provincePaths ||
        oldDelegate.districtPaths != districtPaths ||
        oldDelegate.provinceLabelPositions != provinceLabelPositions ||
        oldDelegate.selectedDistrictName != selectedDistrictName ||
        oldDelegate.focusMode != focusMode ||
        oldDelegate.focusedDistrictName != focusedDistrictName ||
        oldDelegate.theme != theme ||
        oldDelegate.districtProgress != districtProgress ||
        oldDelegate.userLocation?.latitude != userLocation?.latitude ||
        oldDelegate.userLocation?.longitude != userLocation?.longitude;
  }
}
