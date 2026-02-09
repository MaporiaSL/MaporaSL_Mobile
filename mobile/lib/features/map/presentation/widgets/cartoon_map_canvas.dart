import 'package:flutter/material.dart';
import '../../data/regions_data.dart';
import '../../data/geojson_parser.dart';
import '../painters/cartoon_map_painter.dart';
import '../theme/map_visual_theme.dart';

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
  final MapVisualTheme theme;
  final double pulseValue;

  const CartoonMapCanvas({
    super.key,
    required this.regions,
    this.selectedRegionId,
    this.selectedDistrictName,
    this.onRegionTapped,
    this.onRegionSelected,
    this.onDistrictSelected,
    this.theme = const MapVisualTheme(),
    this.pulseValue = 0,
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
  Size? _lastSize;
  Map<String, List<Path>> _provincePaths = {};
  Map<String, List<Path>> _districtPaths = {};
  Map<String, Offset> _provinceLabelPositions = {};
  bool _pathsReady = false;

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

      final intersect =
          ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx <
              (xj - xi) * (point.dy - yi) / ((yj - yi) == 0 ? 1 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }

    return inside;
  }

  void _rebuildPathCache(Size size) {
    if (!_boundariesLoaded) return;
    if (_lastSize == size && _pathsReady) return;

    _lastSize = size;
    _provincePaths = _buildPathMap(_provinceBoundaries, size);
    _districtPaths = _buildPathMap(_districtBoundaries, size);
    _provinceLabelPositions = _buildLabelPositions(_provinceBoundaries, size);
    _pathsReady = true;
  }

  Map<String, List<Path>> _buildPathMap(
    Map<String, List<List<Offset>>> boundaries,
    Size size,
  ) {
    final result = <String, List<Path>>{};
    for (final entry in boundaries.entries) {
      final paths = <Path>[];
      for (final polygon in entry.value) {
        final path = Path();
        if (polygon.isEmpty) continue;

        final first = _normalizeCoordinates(polygon[0], size);
        path.moveTo(first.dx, first.dy);
        for (int i = 1; i < polygon.length; i++) {
          final point = _normalizeCoordinates(polygon[i], size);
          path.lineTo(point.dx, point.dy);
        }
        path.close();
        paths.add(path);
      }
      result[entry.key] = paths;
    }
    return result;
  }

  Map<String, Offset> _buildLabelPositions(
    Map<String, List<List<Offset>>> boundaries,
    Size size,
  ) {
    final result = <String, Offset>{};
    for (final entry in boundaries.entries) {
      final centroid = _calculateCentroid(entry.value);
      result[entry.key] = _normalizeCoordinates(centroid, size);
    }
    return result;
  }

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

  Offset _normalizeCoordinates(Offset coord, Size size) {
    const minLat = 5.9;
    const maxLat = 9.95;
    const minLon = 79.65;
    const maxLon = 81.95;

    final lon = coord.dx;
    final lat = coord.dy;

    final x = ((lon - minLon) / (maxLon - minLon)) * size.width;
    final y = ((maxLat - lat) / (maxLat - minLat)) * size.height;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_boundariesLoaded) {
          _rebuildPathCache(size);
        }

        if (!_boundariesLoaded || !_pathsReady) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTapDown: (details) {
            final tappedRegionId = _getTappedRegion(
              details.localPosition,
              size,
            );
            if (tappedRegionId != null) {
              final provinceName = _districtToProvince[tappedRegionId];
              widget.onRegionSelected?.call(tappedRegionId);
              widget.onDistrictSelected?.call(tappedRegionId, provinceName);
              widget.onRegionTapped?.call();
            }
          },
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              willChange: true,
              painter: CartoonMapPainter(
                regions: _regions,
                selectedRegionId: widget.selectedRegionId,
                selectedDistrictName: widget.selectedDistrictName,
                provincePaths: _provincePaths,
                districtPaths: _districtPaths,
                provinceLabelPositions: _provinceLabelPositions,
                theme: widget.theme,
                pulseValue: widget.pulseValue,
              ),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
}
