import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../data/regions_data.dart';
import '../theme/map_visual_theme.dart';

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
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw base background (Water/Empty space)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      Paint()..color = theme.backgroundColor,
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

    // 7. Draw outer border
    _drawBorders(canvas, size);
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

  /// Draw all districts with progressive unlock colors
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

      // Gradually clear fog: lerp between lockedColor (Fog) and target progress color
      final targetColor = theme.getDistrictProgressColor(progress);
      var fillColor =
          Color.lerp(theme.lockedColor, targetColor, progress) ??
          theme.lockedColor;
      if (isFocusedDistrict && focusMode) {
        fillColor =
            Color.lerp(fillColor, theme.selectedDistrictGlassTint, 0.45) ??
            theme.selectedDistrictGlassTint;
      }
      final opacity = shouldDim
          ? 0.12
          : (isFocusedDistrict && focusMode
                ? 0.92
                : (progress == 0 ? 0.5 : 0.8));

      final fillPaint = Paint()
        ..color = fillColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color =
            (isFocusedDistrict && focusMode
                    ? theme.selectedDistrictBorderColor
                    : theme.borderColor)
                .withValues(alpha: 
                  shouldDim
                      ? 0.06
                      : (isFocusedDistrict && focusMode
                            ? 0.45
                            : 0.1 + (0.1 * progress)),
                )
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      for (final path in districtPathList) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
      }

      // Draw labels for all districts, but opacity depends on progress
      if (!focusMode || isFocusedDistrict) {
        _drawDistrictLabelFor(canvas, districtId, districtPathList, progress);
      }
    }
  }

  /// Calculate centroid and draw district label
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
    final labelOpacity = (0.2 + (0.6 * progress)).clamp(0.0, 1.0);

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
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  /// Draw the fog overlay that covers unexplored areas
  void _drawFogOverlay(Canvas canvas, Size size) {
    if (!focusMode || focusedDistrictName == null) return;

    final paths = districtPaths[focusedDistrictName!];
    if (paths == null || paths.isEmpty) return;

    final layerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(layerRect, Paint());

    final fogPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(layerRect, fogPaint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    for (final path in paths) {
      canvas.drawPath(path, clearPaint);
    }

    canvas.restore();
  }

  /// Add a grainy/noisy procedural texture
  void _drawGrainOverlay(Canvas canvas, Size size) {
    final isDark = theme.backgroundColor.computeLuminance() < 0.5;
    final paint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF334155)).withValues(alpha: 
        0.04,
      )
      ..strokeWidth = 1.0;

    final random = math.Random(42); // Seed for stability
    for (int i = 0; i < 1000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], paint);
    }
  }

  /// Highlight the selected district
  void _drawSelectedDistrictHighlight(Canvas canvas) {
    if (selectedDistrictName == null) return;

    final paths = districtPaths[selectedDistrictName!];
    if (paths == null || paths.isEmpty) return;

    final highlightPaint = Paint()
      ..color = theme.selectedDistrictBorderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final outerGlowPaint = Paint()
      ..color = theme.selectedDistrictGlowColor.withValues(alpha: 0.38)
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      canvas.drawPath(path, outerGlowPaint);
      canvas.drawPath(path, highlightPaint);
    }
  }

  /// Draw simple outer border
  void _drawBorders(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = theme.borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
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
        oldDelegate.focusMode != focusMode ||
        oldDelegate.focusedDistrictName != focusedDistrictName ||
        oldDelegate.theme != theme ||
        oldDelegate.districtProgress != districtProgress;
  }
}

