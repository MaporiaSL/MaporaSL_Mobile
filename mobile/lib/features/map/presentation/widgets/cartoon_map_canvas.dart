import 'package:flutter/material.dart';
import '../../data/regions_data.dart';
import '../../data/geojson_parser.dart';
import '../painters/cartoon_map_painter.dart';

/// Interactive cartoonish map canvas
/// Detects region taps and displays selection feedback
class CartoonMapCanvas extends StatefulWidget {
  final List<SriLankaRegion> regions;
  final String? selectedRegionId;
  final VoidCallback? onRegionTapped;
  final Function(String regionId)? onRegionSelected;

  const CartoonMapCanvas({
    super.key,
    required this.regions,
    this.selectedRegionId,
    this.onRegionTapped,
    this.onRegionSelected,
  });

  @override
  State<CartoonMapCanvas> createState() => _CartoonMapCanvasState();
}

class _CartoonMapCanvasState extends State<CartoonMapCanvas> {
  late List<SriLankaRegion> _regions;
  Map<String, List<List<Offset>>> _provinceBoundaries = {};
  Map<String, List<List<Offset>>> _districtBoundaries = {};
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
      final districts = await GeoJsonParser.loadDistrictBoundaries();
      setState(() {
        _provinceBoundaries = provinces;
        _districtBoundaries = districts;
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

    const tapRadius = 50.0; // Tap detection radius in pixels

    for (final region in _regions) {
      final x = ((region.longitude - minLon) / (maxLon - minLon)) * size.width;
      final y = ((maxLat - region.latitude) / (maxLat - minLat)) * size.height;

      final distance = (position - Offset(x, y)).distance;
      if (distance < tapRadius) {
        return region.id;
      }
    }
    return null;
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
          widget.onRegionSelected?.call(tappedRegionId);
          widget.onRegionTapped?.call();
        }
      },
      child: CustomPaint(
        painter: CartoonMapPainter(
          regions: _regions,
          selectedRegionId: widget.selectedRegionId,
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
