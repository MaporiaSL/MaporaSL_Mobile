import 'package:flutter/material.dart';
import '../../data/regions_data.dart';
import '../theme/map_visual_theme.dart';

/// Cartoonish painter for rendering stylized Sri Lanka map with GeoJSON boundaries
/// Renders actual province and district outlines, boundaries, and colors
class CartoonMapPainter extends CustomPainter {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final Map<String, List<Path>> provincePaths;
  final Map<String, List<Path>> districtPaths;
  final Map<String, Offset> provinceLabelPositions;
  final String? selectedDistrictName;
  final MapVisualTheme theme;
  final double pulseValue;

  CartoonMapPainter({
    required this.regions,
    this.selectedRegionId,
    required this.provincePaths,
    required this.districtPaths,
    required this.provinceLabelPositions,
    this.selectedDistrictName,
    required this.theme,
    this.pulseValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background (ocean color)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.oceanColor,
    );

    _drawLandShadow(canvas);

    // Draw province extrusion sides first
    _drawExtrusion(canvas);

    // Draw all provinces with their colors
    for (final region in regions) {
      final isSelected = region.id == selectedRegionId;
      final fillColor = theme.resolveRegionFill(
        region.id,
        region.color.toFlutterColor(),
      );
      final fillPaint = Paint()
        ..shader = theme.unlockedGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..color = fillColor
        ..style = PaintingStyle.fill;
      _drawRegionWithBoundaries(canvas, size, region, fillPaint, isSelected);
    }

    // Selected district highlight fill/glow
    _drawSelectedDistrictHighlight(canvas);

    // Draw district boundaries on top
    _drawDistrictBoundaries(canvas);

    // Fog of war overlay for locked districts
    _drawFogOfWar(canvas, size);

    // Coast glow
    _drawOceanGlow(canvas);

    // Draw outer border
    _drawBorders(canvas, size);
  }

  /// Draw all district boundaries
  void _drawDistrictBoundaries(Canvas canvas) {
    final runeGlowPaint = Paint()
      ..color = theme.runeGlowColor
      ..strokeWidth = theme.districtBorderWidth + 2
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.runeGlowBlur);

    final districtBorderPaint = Paint()
      ..color = theme.districtBorderColor
      ..strokeWidth = theme.districtBorderWidth
      ..style = PaintingStyle.stroke;

    final selectedBorderPaint = Paint()
      ..color = theme.selectedDistrictBorderColor
      ..strokeWidth = theme.selectedDistrictBorderWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + pulseValue * 6);

    for (final entry in districtPaths.entries) {
      final isSelected = entry.key == selectedDistrictName;
      for (final path in entry.value) {
        canvas.drawPath(path, runeGlowPaint);
        canvas.drawPath(
          path,
          isSelected ? selectedBorderPaint : districtBorderPaint,
        );
      }
    }
  }

  void _drawSelectedDistrictHighlight(Canvas canvas) {
    if (selectedDistrictName == null) return;
    final paths = districtPaths[selectedDistrictName!];
    if (paths == null || paths.isEmpty) return;

    final highlightColor = theme.selectedDistrictBorderColor;
    final fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.14 + (pulseValue * 0.16))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + pulseValue * 6);

    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.selectedDistrictBorderWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (final path in paths) {
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, glowPaint);
    }
  }

  /// Draw region with actual GeoJSON boundaries
  void _drawRegionWithBoundaries(
    Canvas canvas,
    Size size,
    SriLankaRegion region,
    Paint paint,
    bool isSelected,
  ) {
    // Find matching boundary for this region
    List<Path>? polygons;
    String? matchedKey;

    // Try multiple matching strategies
    for (final entry in provincePaths.entries) {
      final keyLower = entry.key.toLowerCase();
      final displayLower = region.displayName.toLowerCase();

      // Match "Western Province" with "Western", etc.
      if (keyLower.contains(displayLower) ||
          displayLower.contains(keyLower.split(' ')[0])) {
        polygons = entry.value;
        matchedKey = entry.key;
        break;
      }
    }

    if (polygons == null) {
      print('Warning: No boundary found for ${region.displayName}');
      return;
    }

    // Draw all polygons for this region with filled color
    final borderPaint = Paint()
      ..color = theme.provinceBorderColor
      ..strokeWidth = theme.provinceBorderWidth
      ..style = PaintingStyle.stroke;

    final rimPaint = Paint()
      ..color = theme.rimLightColor
      ..strokeWidth = theme.rimLightWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final selectedBorderPaint = Paint()
      ..color = theme.selectedProvinceBorderColor
      ..strokeWidth = theme.selectedProvinceBorderWidth
      ..style = PaintingStyle.stroke;

    for (final path in polygons) {
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
      canvas.drawPath(path, rimPaint);
      if (isSelected) {
        canvas.drawPath(path, selectedBorderPaint);
      }
    }

    // Draw region label at center
    if (matchedKey != null) {
      final labelPos = provinceLabelPositions[matchedKey];
      if (labelPos != null) {
        _drawRegionLabel(canvas, region.displayName, labelPos);
      }
    }
  }

  void _drawLandShadow(Canvas canvas) {
    if (provincePaths.isEmpty) return;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.shadowBlur);

    for (final entry in provincePaths.entries) {
      for (final path in entry.value) {
        canvas.drawPath(path.shift(theme.shadowOffset), shadowPaint);
      }
    }
  }

  void _drawExtrusion(Canvas canvas) {
    if (provincePaths.isEmpty) return;

    final sidePaint = Paint()
      ..color = theme.extrusionSideColor
      ..style = PaintingStyle.fill;

    final offset = Offset(theme.extrusionDepth, theme.extrusionDepth);

    for (final entry in provincePaths.entries) {
      for (final path in entry.value) {
        canvas.drawPath(path.shift(offset), sidePaint);
      }
    }
  }

  void _drawOceanGlow(Canvas canvas) {
    final glowPaint = Paint()
      ..color = theme.oceanGlowColor
      ..strokeWidth = theme.oceanGlowWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (final entry in provincePaths.entries) {
      for (final path in entry.value) {
        canvas.drawPath(path, glowPaint);
      }
    }
  }

  void _drawFogOfWar(Canvas canvas, Size size) {
    if (theme.lockedDistrictIds.isEmpty) return;

    final fogPaint = Paint()
      ..shader = theme.fogGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..color = Colors.white.withOpacity(theme.fogOpacity)
      ..style = PaintingStyle.fill;

    final fogShadow = Paint()
      ..color = theme.fogShadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.fogShadowBlur)
      ..style = PaintingStyle.fill;

    for (final entry in districtPaths.entries) {
      if (!theme.lockedDistrictIds.contains(entry.key)) continue;

      for (final path in entry.value) {
        canvas.drawPath(path, fogPaint);
        canvas.drawPath(path.shift(const Offset(2, 3)), fogShadow);

        _drawFogClouds(canvas, path, size);
      }
    }
  }

  void _drawFogClouds(Canvas canvas, Path clipPath, Size size) {
    canvas.save();
    canvas.clipPath(clipPath);

    final cloudPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.85),
          const Color(0xFF1B2B45).withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    for (int i = 0; i < 7; i++) {
      final dx = (size.width * (0.15 + i * 0.1)) % size.width;
      final dy = (size.height * (0.2 + i * 0.12)) % size.height;
      canvas.drawCircle(Offset(dx, dy), 40 + i * 6.0, cloudPaint);
    }

    canvas.restore();
  }

  /// Draw region name label
  void _drawRegionLabel(Canvas canvas, String label, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: theme.labelStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  /// Draw province borders and coastline
  void _drawBorders(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = theme.coastlineColor
      ..strokeWidth = theme.coastlineWidth
      ..style = PaintingStyle.stroke;

    // Draw coastline border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      borderPaint,
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
        oldDelegate.theme != theme ||
        oldDelegate.pulseValue != pulseValue;
  }
}
