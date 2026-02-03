import 'package:flutter/material.dart';
import '../../data/regions_data.dart';

/// Cartoonish painter for rendering stylized Sri Lanka map with GeoJSON boundaries
/// Renders actual province and district outlines, boundaries, and colors
class CartoonMapPainter extends CustomPainter {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final Map<String, List<List<Offset>>> provinceBoundaries;
  final Map<String, List<List<Offset>>> districtBoundaries;
  final Paint Function(HexColor color, bool isSelected) paintBuilder;

  CartoonMapPainter({
    required this.regions,
    this.selectedRegionId,
    required this.provinceBoundaries,
    required this.districtBoundaries,
    required this.paintBuilder,
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
      Paint()..color = const Color(0xFF1A5F7A), // Deep ocean blue
    );

    // Draw all provinces with their colors
    for (final region in regions) {
      final isSelected = region.id == selectedRegionId;
      final paint = paintBuilder(region.color, isSelected);
      _drawRegionWithBoundaries(canvas, size, region, paint);
    }

    // Draw district boundaries on top
    _drawDistrictBoundaries(canvas, size);

    // Draw outer border
    _drawBorders(canvas, size);
  }

  /// Draw all district boundaries
  void _drawDistrictBoundaries(Canvas canvas, Size size) {
    final districtBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final entry in districtBoundaries.entries) {
      for (final polygon in entry.value) {
        _drawPolygonBorder(canvas, size, polygon, districtBorderPaint);
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
    for (final polygon in polygons) {
      _drawPolygon(canvas, size, polygon, paint);
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

    // Draw filled province with vibrant color
    canvas.drawPath(path, paint);

    // Draw strong border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
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
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black87),
          ],
        ),
      ),
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
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
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
        oldDelegate.districtBoundaries != districtBoundaries;
  }
}
