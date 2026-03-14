import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../core/constants/app_colors.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';
import 'theme/map_visual_theme.dart';
import '../../exploration/providers/exploration_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../exploration/data/models/exploration_models.dart';
import '../../visits/presentation/widgets/dynamic_visit_sheet.dart';

final districtFocusProvider = StateProvider<bool>((ref) => false);

/// Lightweight map screen displaying stylized Sri Lanka map with exploration assignments
class MapScreen extends ConsumerStatefulWidget {
  final String travelId;

  const MapScreen({super.key, required this.travelId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? selectedDistrict;
  String? selectedProvince;
  bool _isDistrictFocused = false;
  ExplorationLocation? _selectedLocation;

  String _normalizeKey(String? value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  DistrictAssignment? _assignmentForDistrict(
    List<DistrictAssignment> assignments,
    String? district,
  ) {
    if (district == null || district.isEmpty) return null;
    final districtKey = _normalizeKey(district);
    for (final assignment in assignments) {
      if (_normalizeKey(assignment.district) == districtKey) {
        return assignment;
      }
    }
    return null;
  }

  /// Calculate district progress map from assignments (0.0-1.0 for each district)
  Map<String, double> _calculateDistrictProgress(
    List<DistrictAssignment> assignments,
  ) {
    final progress = <String, double>{};
    for (final assignment in assignments) {
      final percentage = assignment.assignedCount > 0
          ? assignment.visitedCount / assignment.assignedCount
          : 0.0;
      progress[assignment.district.toLowerCase().trim()] = percentage;
    }
    return progress;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(explorationProvider.notifier).loadAssignments();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _exitDistrictFocus() {
    setState(() {
      selectedDistrict = null;
      selectedProvince = null;
      _isDistrictFocused = false;
      _selectedLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ExplorationState>(explorationProvider, (previous, next) {
      // Show error messages
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Show success message when verification completes
      if (previous?.isVerifying == true &&
          !next.isVerifying &&
          next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Location verified successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    final explorationState = ref.watch(explorationProvider);
    final assignments = explorationState.assignments;
    final selectedAssignment = _assignmentForDistrict(
      assignments,
      selectedDistrict,
    );

    // Calculate district progress (0.0-1.0 for each district)
    final districtProgress = _calculateDistrictProgress(assignments);

    // Watch the global theme provider
    final mapThemeStr = ref.watch(themeProvider);
    final theme = (mapThemeStr == 'dark')
        ? MapVisualTheme.dark()
        : const MapVisualTheme();

    // Update district focus state asynchronously after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(districtFocusProvider.notifier).state = _isDistrictFocused;
    });

    if (_isDistrictFocused && selectedAssignment != null) {
      return Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.02),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              _DistrictVectorMap(
                key: ValueKey(
                  'district-map-${selectedAssignment.district.toLowerCase()}',
                ),
                assignment: selectedAssignment,
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _DistrictHeaderBar(
                  district: selectedDistrict ?? 'District',
                  onExit: _exitDistrictFocus,
                ),
              ),
              if (_selectedLocation != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _PlaceDetailCard(
                    location: _selectedLocation!,
                    onClose: () {
                      setState(() {
                        _selectedLocation = null;
                      });
                    },
                    onVerify: () {
                      final location = _selectedLocation;
                      if (location == null) return;
                      DynamicVisitSheet.show(
                        context,
                        placeId: location.id,
                        placeName: location.name,
                        targetLat: location.latitude,
                        targetLng: location.longitude,
                        isExploration: true,
                        explorationLocation: location,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🗺️ Discover Sri Lanka',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  transformAlignment: Alignment.topLeft,
                  transform: Matrix4.identity(),
                  child: Stack(
                    children: [
                      CartoonMapCanvas(
                        regions: sriLankaRegions,
                        selectedRegionId: selectedProvince,
                        selectedDistrictName: selectedDistrict,
                        focusMode: _isDistrictFocused,
                        focusedDistrictName: selectedDistrict,
                        theme: theme,
                        districtProgress: districtProgress,
                        onDistrictSelected:
                            (
                              districtName,
                              provinceName,
                              tapFraction,
                              focusTarget,
                            ) {
                              setState(() {
                                if (districtName.isEmpty) {
                                  selectedDistrict = null;
                                  selectedProvince = null;
                                  _isDistrictFocused = false;
                                  _selectedLocation = null;
                                  return;
                                }

                                final sameDistrict =
                                    _normalizeKey(selectedDistrict) ==
                                    _normalizeKey(districtName);
                                if (sameDistrict && _isDistrictFocused) {
                                  selectedDistrict = null;
                                  selectedProvince = null;
                                  _isDistrictFocused = false;
                                  _selectedLocation = null;
                                  return;
                                }

                                selectedDistrict = districtName;
                                selectedProvince =
                                    (provinceName != null &&
                                        provinceName.isNotEmpty)
                                    ? provinceName
                                    : null;
                                _isDistrictFocused = true;
                                _selectedLocation = null;
                              });
                            },
                      ),
                    ],
                  ),
                ),

                if (_selectedLocation != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _PlaceDetailCard(
                      location: _selectedLocation!,
                      onClose: () {
                        setState(() {
                          _selectedLocation = null;
                        });
                      },
                      onVerify: () {
                        final location = _selectedLocation;
                        if (location == null) return;
                        DynamicVisitSheet.show(
                          context,
                          placeId: location.id,
                          placeName: location.name,
                          targetLat: location.latitude,
                          targetLng: location.longitude,
                          isExploration: true,
                          explorationLocation: location,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DistrictHeaderBar extends StatelessWidget {
  final String district;
  final VoidCallback onExit;

  const _DistrictHeaderBar({
    required this.district,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  district,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onExit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceDetailCard extends StatelessWidget {
  final ExplorationLocation location;
  final VoidCallback onClose;
  final VoidCallback onVerify;

  const _PlaceDetailCard({
    required this.location,
    required this.onClose,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = location.photos.isNotEmpty ? location.photos.first : null;
    return Semantics(
      label: 'Place details for ${location.name}',
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackHeader(),
                ),
              )
            else
              _fallbackHeader(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(location.type.isEmpty ? 'Attraction' : location.type),
                  const SizedBox(height: 8),
                  Text(
                    location.description?.isNotEmpty == true
                        ? location.description!
                        : 'No description available yet. Visit this location to contribute better details.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: location.visited ? null : onVerify,
                      icon: const Icon(Icons.verified),
                      label: Text(
                        location.visited
                            ? 'Already Verified'
                            : 'Verify This Place',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(Icons.photo, size: 40, color: Color(0xFF64748B)),
      ),
    );
  }
}

class _DistrictVectorMap extends StatefulWidget {
  final DistrictAssignment assignment;
  final ValueChanged<ExplorationLocation> onLocationSelected;

  const _DistrictVectorMap({
    super.key,
    required this.assignment,
    required this.onLocationSelected,
  });

  @override
  State<_DistrictVectorMap> createState() => _DistrictVectorMapState();
}

class _DistrictVectorMapState extends State<_DistrictVectorMap> {
  static const String _districtSourceId = 'district-focus-source';
  static const String _districtFillLayerId = 'district-focus-fill';
  static const String _districtLineLayerId = 'district-focus-line';
  static const String _outsideMaskSourceId = 'district-outside-mask-source';
  static const String _outsideMaskLayerId = 'district-outside-mask-fill';
  static Map<String, dynamic>? _districtGeoJsonCache;

  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _pointManager;
  mapbox.Cancelable? _tapCancelable;
  String? _selectedDistrictGeoJson;
  String? _outsideMaskGeoJson;
  final Map<String, ExplorationLocation> _locationsByAnnotationId =
      <String, ExplorationLocation>{};

  @override
  void didUpdateWidget(covariant _DistrictVectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKey = oldWidget.assignment.district.toLowerCase();
    final newKey = widget.assignment.district.toLowerCase();
    if (oldKey != newKey) {
      _reloadDistrictData();
    }
  }

  @override
  void dispose() {
    _tapCancelable?.cancel();
    _tapCancelable = null;
    _clearDistrictLayers();
    _pointManager = null;
    _mapboxMap = null;
    super.dispose();
  }

  String _normalizeDistrict(String value) {
    final alphanumericOnly = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return alphanumericOnly.trim();
  }

  Future<Map<String, dynamic>> _loadDistrictGeoJson() async {
    if (_districtGeoJsonCache != null) {
      return _districtGeoJsonCache!;
    }

    final raw = await rootBundle.loadString(
      'assets/geojson/boundaries/LK-districts.geojson',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('District GeoJSON is not a valid object');
    }
    _districtGeoJsonCache = decoded;
    return decoded;
  }

  Map<String, dynamic>? _findDistrictFeature(Map<String, dynamic> geoJson) {
    final features = geoJson['features'];
    if (features is! List) return null;

    final target = _normalizeDistrict(widget.assignment.district);
    if (target.isEmpty) return null;

    Map<String, dynamic>? fuzzyMatch;
    for (final entry in features) {
      if (entry is! Map<String, dynamic>) continue;
      final properties = entry['properties'];
      if (properties is! Map<String, dynamic>) continue;

      final name = (properties['NAME_1'] ?? properties['name'])?.toString();
      if (name == null || name.isEmpty) continue;

      final token = _normalizeDistrict(name);
      if (token == target) {
        return entry;
      }

      if (token.contains(target) || target.contains(token)) {
        fuzzyMatch ??= entry;
      }
    }

    return fuzzyMatch;
  }

  String? _buildDistrictGeoJson(Map<String, dynamic>? feature) {
    if (feature == null) return null;
    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [feature],
    });
  }

  List<List<dynamic>> _extractOuterRings(Map<String, dynamic>? geometry) {
    if (geometry == null) return const <List<dynamic>>[];
    final type = geometry['type']?.toString();
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) {
      return const <List<dynamic>>[];
    }

    final rings = <List<dynamic>>[];

    if (type == 'Polygon') {
      final polygon = coordinates.first;
      if (polygon is List && polygon.isNotEmpty) {
        final outer = polygon.first;
        if (outer is List) {
          rings.add(List<dynamic>.from(outer));
        }
      }
    } else if (type == 'MultiPolygon') {
      for (final polygon in coordinates) {
        if (polygon is! List || polygon.isEmpty) continue;
        final outer = polygon.first;
        if (outer is List) {
          rings.add(List<dynamic>.from(outer));
        }
      }
    }

    return rings;
  }

  String? _buildOutsideMaskGeoJson(Map<String, dynamic>? feature) {
    if (feature == null) return null;
    final geometry = feature['geometry'];
    if (geometry is! Map<String, dynamic>) return null;

    final holes = _extractOuterRings(geometry);
    if (holes.isEmpty) return null;

    final worldRing = <List<double>>[
      <double>[-180.0, -85.0],
      <double>[180.0, -85.0],
      <double>[180.0, 85.0],
      <double>[-180.0, 85.0],
      <double>[-180.0, -85.0],
    ];

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'Polygon',
            'coordinates': <dynamic>[worldRing, ...holes],
          },
        },
      ],
    });
  }

  Future<void> _prepareDistrictGeometry() async {
    try {
      final geoJson = await _loadDistrictGeoJson();
      final feature = _findDistrictFeature(geoJson);
      _selectedDistrictGeoJson = _buildDistrictGeoJson(feature);
      _outsideMaskGeoJson = _buildOutsideMaskGeoJson(feature);
    } catch (_) {
      _selectedDistrictGeoJson = null;
      _outsideMaskGeoJson = null;
    }
  }

  Future<void> _removeStyleLayer(String layerId) async {
    final map = _mapboxMap;
    if (map == null) return;
    try {
      await (map.style as dynamic).removeLayer(layerId);
    } catch (_) {
      // Layer may not exist yet.
    }
  }

  Future<void> _removeStyleSource(String sourceId) async {
    final map = _mapboxMap;
    if (map == null) return;
    try {
      await (map.style as dynamic).removeStyleSource(sourceId);
    } catch (_) {
      // Source may not exist yet.
    }
  }

  Future<void> _clearDistrictLayers() async {
    await _removeStyleLayer(_districtLineLayerId);
    await _removeStyleLayer(_districtFillLayerId);
    await _removeStyleLayer(_outsideMaskLayerId);
    await _removeStyleSource(_districtSourceId);
    await _removeStyleSource(_outsideMaskSourceId);
  }

  Future<void> _applyDistrictLayers(mapbox.MapboxMap map) async {
    await _clearDistrictLayers();

    final districtGeoJson = _selectedDistrictGeoJson;
    if (districtGeoJson == null) return;

    final districtSource = mapbox.GeoJsonSource(
      id: _districtSourceId,
      data: districtGeoJson,
    );
    await map.style.addSource(districtSource);

    // Add district fill layer (spotlight effect with transparency)
    await map.style.addLayer(
      mapbox.FillLayer(
        id: _districtFillLayerId,
        sourceId: _districtSourceId,
        fillColor: const Color(0xFF22C55E).toARGB32(),
        fillOpacity: 0.08,
      ),
    );

    // Add district boundary line (strong visibility)
    await map.style.addLayer(
      mapbox.LineLayer(
        id: _districtLineLayerId,
        sourceId: _districtSourceId,
        lineColor: const Color(0xFF22C55E).toARGB32(),
        lineOpacity: 0.9,
        lineWidth: 3.0,
      ),
    );

    // Add outside mask LAST so it renders on top and hides everything outside
    final outsideMaskGeoJson = _outsideMaskGeoJson;
    if (outsideMaskGeoJson != null) {
      final maskSource = mapbox.GeoJsonSource(
        id: _outsideMaskSourceId,
        data: outsideMaskGeoJson,
      );
      await map.style.addSource(maskSource);
      await map.style.addLayer(
        mapbox.FillLayer(
          id: _outsideMaskLayerId,
          sourceId: _outsideMaskSourceId,
          fillColor: 0xFF000000,
          fillOpacity: 1.0,
        ),
      );
    }
  }

  mapbox.CameraOptions _initialCamera() {
    if (widget.assignment.center != null) {
      return mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            widget.assignment.center!.longitude,
            widget.assignment.center!.latitude,
          ),
        ),
        zoom: 10.8,
      );
    }

    final first = widget.assignment.locations.isNotEmpty
        ? widget.assignment.locations.first
        : null;
    return mapbox.CameraOptions(
      center: mapbox.Point(
        coordinates: mapbox.Position(
          first?.longitude ?? 80.7718,
          first?.latitude ?? 7.8731,
        ),
      ),
      zoom: 9.5,
    );
  }

  Future<void> _fitToDistrict(mapbox.MapboxMap map) async {
    final bounds = widget.assignment.bounds;
    if (bounds != null) {
      final sw = mapbox.Point(
        coordinates: mapbox.Position(bounds.minLng, bounds.minLat),
      );
      final ne = mapbox.Point(
        coordinates: mapbox.Position(bounds.maxLng, bounds.maxLat),
      );

      try {
        // Set camera bounds to prevent panning outside district
        await map.setBounds(
          mapbox.CameraBoundsOptions(
            bounds: mapbox.CoordinateBounds(
              southwest: sw,
              northeast: ne,
              infiniteBounds: false,
            ),
            minZoom: 7.5,
            maxZoom: 13.5,
          ),
        );

        // Calculate optimal camera to fit entire district in frame
        final camera = await map.cameraForCoordinateBounds(
          mapbox.CoordinateBounds(
            southwest: sw,
            northeast: ne,
            infiniteBounds: false,
          ),
          mapbox.MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
          null,
          null,
          8.5,
          null,
        );
        await map.easeTo(camera, mapbox.MapAnimationOptions(duration: 700));
        return;
      } catch (_) {
        // Fall back to center zoom when bounds fit cannot be calculated yet.
      }
    }

    if (widget.assignment.center != null) {
      await map.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              widget.assignment.center!.longitude,
              widget.assignment.center!.latitude,
            ),
          ),
          zoom: 10.8,
        ),
      );
    }
  }

  Future<void> _setupMarkers(mapbox.MapboxMap map) async {
    final previousManager = _pointManager;
    if (previousManager != null) {
      _tapCancelable?.cancel();
      _tapCancelable = null;
      await map.annotations.removeAnnotationManager(previousManager);
      _pointManager = null;
    }

    final manager = await map.annotations.createPointAnnotationManager();
    _pointManager = manager;
    await manager.setIconAllowOverlap(true);
    await manager.setIconIgnorePlacement(true);

    final markerOptions = widget.assignment.locations
        .map(
          (location) => mapbox.PointAnnotationOptions(
            geometry: mapbox.Point(
              coordinates: mapbox.Position(
                location.longitude,
                location.latitude,
              ),
            ),
            iconImage: location.visited ? 'marker-visited' : 'marker-unvisited',
            iconSize: location.visited ? 2.0 : 1.6,
            iconColor: location.visited
                ? const Color(0xFF10B981).toARGB32()
                : const Color(0xFFEF4444).toARGB32(),
            iconOpacity: location.visited ? 1.0 : 0.85,
          ),
        )
        .toList(growable: false);

    final annotations = await manager.createMulti(markerOptions);
    _locationsByAnnotationId.clear();
    for (int i = 0; i < annotations.length; i++) {
      final annotation = annotations[i];
      if (annotation == null) continue;
      _locationsByAnnotationId[annotation.id] = widget.assignment.locations[i];
    }

    _tapCancelable = manager.tapEvents(
      onTap: (annotation) {
        final location = _locationsByAnnotationId[annotation.id];
        if (location != null) {
          widget.onLocationSelected(location);
        }
      },
    );
  }

  Future<void> _reloadDistrictData() async {
    final map = _mapboxMap;
    if (map == null) return;

    await _prepareDistrictGeometry();
    await _applyDistrictLayers(map);
    await _fitToDistrict(map);
    await _setupMarkers(map);
  }

  void _handleMapTap(mapbox.MapContentGestureContext tapContext) {
    final tapped = tapContext.point.coordinates;
    final candidates = widget.assignment.locations
        .where((location) {
          final distance = _distanceMeters(
            tapped.lat.toDouble(),
            tapped.lng.toDouble(),
            location.latitude,
            location.longitude,
          );
          return distance <= 160;
        })
        .toList(growable: false);

    if (candidates.isEmpty) return;

    if (candidates.length == 1) {
      widget.onLocationSelected(candidates.first);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Nearby Markers'),
                subtitle: Text('Multiple places overlap here. Select one.'),
              ),
              ...candidates.map(
                (location) => ListTile(
                  leading: Icon(
                    location.visited
                        ? Icons.check_circle
                        : Icons.location_on_outlined,
                    color: location.visited
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  title: Text(location.name),
                  subtitle: Text(
                    location.visited ? 'Visited • ${location.type}' : location.type,
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onLocationSelected(location);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            (math.sin(dLon / 2) * math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double value) => value * 0.017453292519943295;

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      key: ValueKey(
        'district-mapbox-${widget.assignment.district.toLowerCase()}',
      ),
      styleUri: 'mapbox://styles/mapbox/streets-v12',
      cameraOptions: _initialCamera(),
      onMapCreated: (map) async {
        _mapboxMap = map;
        await _reloadDistrictData();
      },
      onTapListener: _handleMapTap,
    );
  }
}
