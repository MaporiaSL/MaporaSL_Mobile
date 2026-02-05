import 'package:flutter/material.dart';
import '../../data/regions_data.dart';
import '../../data/geojson_parser.dart';
import '../painters/cartoon_map_painter.dart';

/// Interactive cartoonish map canvas
/// Detects region taps and displays selection feedback
class CartoonMapCanvas extends StatefulWidget {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final String? selectedDistrictName;
  final VoidCallback? onRegionTapped;
  final Function(String regionId)? onRegionSelected;
  final void Function(String districtName, String? provinceName)?
  onDistrictSelected;

  const CartoonMapCanvas({
    super.key,
    required this.regions,
    this.selectedRegionId,
    this.selectedDistrictName,
    this.onRegionTapped,
    this.onRegionSelected,
    this.onDistrictSelected,
  });

  @override
  State<CartoonMapCanvas> createState() => _CartoonMapCanvasState();
}

class _CartoonMapCanvasState extends State<CartoonMapCanvas> {
  late List<SriLankaRegion> _regions;
  Map<String, List<List<Offset>>> _provinceBoundaries = {};
  Map<String, List<List<Offset>>> _districtBoundaries = {};
  Map<String, String> _districtToProvince = {};
  bool _boundariesLoaded = false;

  @override
  void initState() {
    super.initState();
    _regions = widget.regions;
    _loadBoundaries();
  }

  /// Load GeoJSON boundaries
  Future<void> _loadBoundaries() async {
    try {
      final provinces = await GeoJsonParser.loadProvinceBoundaries();
      final districtData = await GeoJsonParser.loadDistrictBoundaryData();
      setState(() {
        _provinceBoundaries = provinces;
        _districtBoundaries = districtData.boundaries;
        _districtToProvince = districtData.districtToProvince;
        _boundariesLoaded = true;
      });
    } catch (e) {
      print('Error loading boundaries: $e');
      setState(() => _boundariesLoaded = true);
    }
  }

  @override
  void didUpdateWidget(CartoonMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.regions != widget.regions) {
      _regions = widget.regions;
    }
  }

  /// Check if tap is on a region (using province centers)
  String? _getTappedRegion(Offset position, Size size) {
    const minLat = 5.9;
    const maxLat = 9.95;
    const minLon = 79.65;
    const maxLon = 81.95;
    final lon = minLon + (position.dx / size.width) * (maxLon - minLon);
    final lat = maxLat - (position.dy / size.height) * (maxLat - minLat);
    final tapPoint = Offset(lon, lat);

    for (final entry in _districtBoundaries.entries) {
      for (final polygon in entry.value) {
        if (_isPointInPolygon(tapPoint, polygon)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;

      // Skip horizontal edges; they do not contribute to the ray casting algorithm.
      if (yi == yj) {
        continue;
      }

      final intersect = ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx <
              (xj - xi) * (point.dy - yi) / (yj - yi) +
                  xi);
      if (intersect) inside = !inside;
    }

    return inside;
  }

  @override
  Widget build(BuildContext context) {
    if (!_boundariesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTapDown: (details) {
        // Get tap position relative to canvas
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;

        final tappedRegionId = _getTappedRegion(details.localPosition, size);
        if (tappedRegionId != null) {
          final provinceName = _districtToProvince[tappedRegionId];
          widget.onRegionSelected?.call(tappedRegionId);
          widget.onDistrictSelected?.call(tappedRegionId, provinceName);
          widget.onRegionTapped?.call();
        }
      },
      child: CustomPaint(
        painter: CartoonMapPainter(
          regions: _regions,
          selectedRegionId: widget.selectedRegionId,
          selectedDistrictName: widget.selectedDistrictName,
          provinceBoundaries: _provinceBoundaries,
          districtBoundaries: _districtBoundaries,
          paintBuilder: (color, isSelected) {
            final paint = Paint()..color = color.toFlutterColor();

            if (isSelected) {
              paint.strokeWidth = 2;
              paint.style = PaintingStyle.stroke;
            }

            return paint;
          },
        ),
        child: Container(),
      ),
    );
  }
}
