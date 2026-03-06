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
    String? matchedKey;

    for (final entry in provincePaths.entries) {
      final keyLower = entry.key.toLowerCase();
      final displayLower = region.displayName.toLowerCase();

      if (keyLower.contains(displayLower) ||
          displayLower.contains(keyLower.split(' ')[0])) {
        polygons = entry.value;
        matchedKey = entry.key;
        break;
      }
    }

    if (polygons == null) return;

    final borderPaint = Paint()
      ..color = theme.borderColor.withOpacity(0.1)
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

      // Get progress for this district
      final progress = districtProgress[districtId] ?? 0.0;
      
      // Gradually clear fog: lerp between lockedColor (Fog) and target progress color
      final targetColor = theme.getDistrictProgressColor(progress);
      final fillColor = Color.lerp(theme.lockedColor, targetColor, progress) ?? theme.lockedColor;

      final fillPaint = Paint()
        ..color = fillColor.withOpacity(progress == 0 ? 0.5 : 0.8)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = theme.borderColor.withOpacity(0.1 + (0.1 * progress))
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      for (final path in districtPathList) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
      }
      
      // Draw labels for all districts, but opacity depends on progress
      _drawDistrictLabelFor(canvas, districtId, districtPathList, progress);
    }
  }

  /// Calculate centroid and draw district label
  void _drawDistrictLabelFor(Canvas canvas, String districtId, List<Path> paths, double progress) {
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
          color: Colors.white.withOpacity(labelOpacity),
          fontSize: 8,
          fontWeight: progress > 0.5 ? FontWeight.bold : FontWeight.normal,
        )
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  /// Draw the fog overlay that covers unexplored areas
  void _drawFogOverlay(Canvas canvas, Size size) {
    // Total fog layer
    final fogPaint = Paint()
      ..color = theme.fogColor.withOpacity(theme.fogOpacity)
      ..style = PaintingStyle.fill;
      
    // Create a path that covers the whole canvas EXCEPT the unlocked districts
    // This is expensive if done every frame, but fine for prototype
    // For simplicity, we just use BlendMode.dstIn or similar if we wanted a hole
    // But since districts are already drawn, let's just use it creatively.
    
    // Instead of a hole, we'll just draw fog over everything then re-highlight selected
  }

  /// Add a grainy/noisy procedural texture
  void _drawGrainOverlay(Canvas canvas, Size size) {
    final isDark = theme.backgroundColor.computeLuminance() < 0.5;
    final paint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF334155)).withOpacity(0.04)
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
      ..color = theme.selectedDistrictBorderColor.withOpacity(0.2)
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      canvas.drawPath(path, outerGlowPaint);
      canvas.drawPath(path, highlightPaint);
    }
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
        oldDelegate.theme != theme ||
        oldDelegate.districtProgress != districtProgress;
  }
}
