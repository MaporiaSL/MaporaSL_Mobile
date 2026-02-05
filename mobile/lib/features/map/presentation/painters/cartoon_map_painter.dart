import 'package:flutter/material.dart';
import '../../data/regions_data.dart';
import '../theme/map_visual_theme.dart';

/// Cartoonish painter for rendering stylized Sri Lanka map with GeoJSON boundaries
/// Renders actual province and district outlines, boundaries, and colors
class CartoonMapPainter extends CustomPainter {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final Map<String, List<List<Offset>>> provinceBoundaries;
  final Map<String, List<List<Offset>>> districtBoundaries;
  final String? selectedDistrictName;
  final MapVisualTheme theme;

  CartoonMapPainter({
    required this.regions,
    this.selectedRegionId,
    required this.provinceBoundaries,
    required this.districtBoundaries,
    this.selectedDistrictName,
    required this.theme,
  });

  /// Sri Lanka geographic bounds (latitude/longitude)
  static const double minLat = 5.9;
  static const double maxLat = 9.95;
  static const double minLon = 79.65;
  static const double maxLon = 81.95;

  @override
  void paint(Canvas canvas, Size size) {
    // Background (ocean color)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.oceanColor,
    );

    // Draw all provinces with their colors
    for (final region in regions) {
      final isSelected = region.id == selectedRegionId;
      final fillColor = theme.resolveRegionFill(
        region.id,
        region.color.toFlutterColor(),
      );
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      _drawRegionWithBoundaries(canvas, size, region, fillPaint, isSelected);
    }

    // Draw district boundaries on top
    _drawDistrictBoundaries(canvas, size);

    // Draw outer border
    _drawBorders(canvas, size);
  }

  /// Draw all district boundaries
  void _drawDistrictBoundaries(Canvas canvas, Size size) {
    final districtBorderPaint = Paint()
      ..color = theme.districtBorderColor
      ..strokeWidth = theme.districtBorderWidth
      ..style = PaintingStyle.stroke;

    final selectedBorderPaint = Paint()
      ..color = theme.selectedDistrictBorderColor
      ..strokeWidth = theme.selectedDistrictBorderWidth
      ..style = PaintingStyle.stroke;

    for (final entry in districtBoundaries.entries) {
      final isSelected = entry.key == selectedDistrictName;
      for (final polygon in entry.value) {
        _drawPolygonBorder(
          canvas,
          size,
          polygon,
          isSelected ? selectedBorderPaint : districtBorderPaint,
        );
      }
    }
  }

  /// Draw polygon border only (no fill)
  void _drawPolygonBorder(
    Canvas canvas,
    Size size,
    List<Offset> polygon,
    Paint paint,
  ) {
    if (polygon.isEmpty) return;

    final path = Path();
    final first = _normalizeCoordinates(polygon[0], size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < polygon.length; i++) {
      final point = _normalizeCoordinates(polygon[i], size);
      path.lineTo(point.dx, point.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
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
    late List<List<Offset>> polygons;
    bool found = false;

    // Try multiple matching strategies
    for (final entry in provinceBoundaries.entries) {
      final keyLower = entry.key.toLowerCase();
      final displayLower = region.displayName.toLowerCase();

      // Match "Western Province" with "Western", etc.
      if (keyLower.contains(displayLower) ||
          displayLower.contains(keyLower.split(' ')[0])) {
        polygons = entry.value;
        found = true;
        break;
      }
    }

    if (!found) {
      print('Warning: No boundary found for ${region.displayName}');
      return;
    }

    // Draw all polygons for this region with filled color
    final borderPaint = Paint()
      ..color = theme.provinceBorderColor
      ..strokeWidth = theme.provinceBorderWidth
      ..style = PaintingStyle.stroke;

    final selectedBorderPaint = Paint()
      ..color = theme.selectedProvinceBorderColor
      ..strokeWidth = theme.selectedProvinceBorderWidth
      ..style = PaintingStyle.stroke;

    for (final polygon in polygons) {
      _drawPolygon(canvas, size, polygon, paint, borderPaint);
      if (isSelected) {
        _drawPolygonBorder(canvas, size, polygon, selectedBorderPaint);
      }
    }

    // Draw region label at center
    final labelPos = _calculateCentroid(polygons);
    _drawRegionLabel(canvas, region.displayName, labelPos, size);
  }

  /// Draw a single polygon (boundary ring)
  void _drawPolygon(
    Canvas canvas,
    Size size,
    List<Offset> polygon,
    Paint paint,
    Paint borderPaint,
  ) {
    if (polygon.isEmpty) return;

    final path = Path();
    final first = _normalizeCoordinates(polygon[0], size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < polygon.length; i++) {
      final point = _normalizeCoordinates(polygon[i], size);
      path.lineTo(point.dx, point.dy);
    }

    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  /// Normalize GeoJSON coordinates (lon, lat) to canvas coordinates
  Offset _normalizeCoordinates(Offset coord, Size size) {
    final lon = coord.dx;
    final lat = coord.dy;

    final x = ((lon - minLon) / (maxLon - minLon)) * size.width;
    final y = ((maxLat - lat) / (maxLat - minLat)) * size.height;

    return Offset(x, y);
  }

  /// Calculate centroid of polygon for label placement
  Offset _calculateCentroid(List<List<Offset>> polygons) {
    double totalLon = 0, totalLat = 0;
    int count = 0;

    for (final polygon in polygons) {
      for (final coord in polygon) {
        totalLon += coord.dx;
        totalLat += coord.dy;
        count++;
      }
    }

    if (count == 0) return Offset.zero;
    return Offset(totalLon / count, totalLat / count);
  }

  /// Draw region name label
  void _drawRegionLabel(
    Canvas canvas,
    String label,
    Offset position,
    Size size,
  ) {
    final normalized = _normalizeCoordinates(position, size);

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: theme.labelStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(
      canvas,
      normalized - Offset(textPainter.width / 2, textPainter.height / 2),
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
        oldDelegate.provinceBoundaries != provinceBoundaries ||
        oldDelegate.districtBoundaries != districtBoundaries ||
        oldDelegate.selectedDistrictName != selectedDistrictName;
  }
}
