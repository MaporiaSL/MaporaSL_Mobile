import 'package:flutter/material.dart';
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
    // Background - white
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.backgroundColor,
    );

    // Light fog overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.fogColor.withOpacity(theme.fogOpacity),
    );

    // Draw all provinces with their base colors
    for (final region in regions) {
      _drawProvince(canvas, size, region);
    }

    // Draw district boundaries and fills
    _drawDistrictsFilled(canvas);

    // Selected district highlight
    _drawSelectedDistrictHighlight(canvas);

    // Draw outer border
    _drawBorders(canvas, size);
  }

  /// Draw a province with its color
  void _drawProvince(Canvas canvas, Size size, SriLankaRegion region) {
    final isSelected = region.id == selectedRegionId;

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

    // Subtle border for provinces
    final borderPaint = Paint()
      ..color = theme.borderColor.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final selectedBorderPaint = Paint()
      ..color = theme.borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final path in polygons) {
      canvas.drawPath(path, borderPaint);
      if (isSelected) {
        canvas.drawPath(path, selectedBorderPaint);
      }
    }

    // Draw province label
    if (matchedKey != null) {
      final labelPos = provinceLabelPositions[matchedKey];
      if (labelPos != null) {
        _drawRegionLabel(canvas, region.displayName, labelPos);
      }
    }
  }

  /// Draw all districts with progressive unlock colors
  void _drawDistrictsFilled(Canvas canvas) {
    for (final entry in districtPaths.entries) {
      final districtId = entry.key;
      final districtPathList = entry.value;

      // Get progress for this district
      final progress = districtProgress[districtId] ?? 0.0;
      final fillColor = theme.getDistrictProgressColor(progress);

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = theme.borderColor
        ..strokeWidth = theme.borderWidth
        ..style = PaintingStyle.stroke;

      final selectedBorderPaint = Paint()
        ..color = theme.selectedDistrictBorderColor
        ..strokeWidth = theme.selectedDistrictBorderWidth
        ..style = PaintingStyle.stroke;

      for (final path in districtPathList) {
        // Draw filled district
        canvas.drawPath(path, fillPaint);

        // Draw border
        canvas.drawPath(path, borderPaint);

        // Highlight selected district
        if (districtId == selectedDistrictName) {
          canvas.drawPath(path, selectedBorderPaint);
        }
      }
    }
  }

  /// Highlight the selected district
  void _drawSelectedDistrictHighlight(Canvas canvas) {
    if (selectedDistrictName == null) return;

    final paths = districtPaths[selectedDistrictName!];
    if (paths == null || paths.isEmpty) return;

    final highlightColor = theme.selectedDistrictBorderColor;
    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (final path in paths) {
      canvas.drawPath(path, glowPaint);
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
