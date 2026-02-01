import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../controllers/map_controller.dart';
import '../models/map_models.dart';
import '../providers/map_provider.dart';
import '../services/map_api_service.dart';
import '../utils/map_style_manager.dart' as styles;

/// Main map screen displaying trip with destinations
class MapScreen extends ConsumerStatefulWidget {
  final String travelId;

  const MapScreen({super.key, required this.travelId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late MapController _mapController;
  MapboxMap? _mapboxMap;
  styles.MapTheme _currentTheme = styles.MapTheme.standard;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadTripData();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Load trip GeoJSON and stats from API
  Future<void> _loadTripData() async {
    final mapStateNotifier = ref.read(mapStateProvider.notifier);

    try {
      // Set loading state
      mapStateNotifier.setCurrentTrip(
        Trip(id: widget.travelId, name: 'Loading...'),
      );

      // Fetch GeoJSON and stats in parallel
      final mapApi = ref.read(mapApiServiceProvider);

      final tripGeoJson = await mapApi.getTravelGeoJson(widget.travelId);
      mapStateNotifier.setTripGeoJson(tripGeoJson);

      // Fetch stats (non-critical, don't block if fails)
      try {
        final stats = await mapApi.getTravelStats(widget.travelId);
        mapStateNotifier.setTripStats(stats);
      } catch (e) {
        debugPrint('Failed to fetch stats: $e');
      }

      // Update map if already initialized
      if (_mapboxMap != null) {
        _loadGeoJsonOnMap(tripGeoJson);
      }
    } catch (e) {
      mapStateNotifier.setError('Failed to load trip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Load GeoJSON onto map
  Future<void> _loadGeoJsonOnMap(TripGeoJson geoJson) async {
    final mapState = ref.read(mapStateProvider);

    await _mapController.loadTripGeoJson(
      geoJson,
      showRoute: mapState.showRoute,
      showBoundary: mapState.showBoundary,
      fitBounds: true,
    );
  }

  void _applyGestureLocks() {
    _mapboxMap?.gestures.updateSettings(
      GesturesSettings(
        rotateEnabled: false,
        pitchEnabled: false,
        simultaneousRotateAndPinchToZoomEnabled: false,
      ),
    );
  }

  void _onStyleLoaded(StyleLoadedEventData data) {
    _applyGestureLocks();
    _mapboxMap?.setCamera(CameraOptions(bearing: 0.0, pitch: 0.0));
  }

  /// Handle map creation
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _mapController.initialize(mapboxMap);

    // Disable rotation and tilt (locked to north-up)
    _applyGestureLocks();

    // Load style based on theme
    _applyTheme(_currentTheme);

    // Set camera to Sri Lanka center with proper zoom
    final center = styles.CameraRestriction.getSriLankaCenter();
    final options = CameraOptions(
      center: Point(
        coordinates: Position(center['longitude']!, center['latitude']!),
      ),
      zoom: 6.5,
      bearing: 0.0, // Lock bearing to north
      pitch: 0.0, // Lock pitch (tilt) to 0
    );
    mapboxMap.setCamera(options);

    // Load existing GeoJSON if available
    final geoJson = ref.read(mapStateProvider).tripGeoJson;
    if (geoJson != null) {
      _loadGeoJsonOnMap(geoJson);
    }
  }

  /// Apply theme and customize map appearance
  void _applyTheme(styles.MapTheme theme) {
    final mapState = ref.read(mapStateProvider);

    switch (theme) {
      case styles.MapTheme.standard:
        _mapboxMap?.loadStyleURI(mapState.mapStyle.url);
        debugPrint('✅ Applied Standard theme');

      case styles.MapTheme.custom:
        // Load custom dark style
        _mapboxMap?.loadStyleURI('mapbox://styles/mapbox/dark-v11');
        debugPrint('✅ Applied Custom theme');

      case styles.MapTheme.fogOfWar:
        // Fog of War - starts with dark, reveals as you visit
        _mapboxMap?.loadStyleURI('mapbox://styles/mapbox/dark-v11');
        debugPrint('✅ Applied Fog of War theme');
    }
  }

  /// Handle theme selection
  void _showThemeOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '🔒 Map is locked to Sri Lanka (no rotation/tilt)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...styles.MapTheme.values.map((theme) {
              return ListTile(
                title: Text(theme.displayName),
                trailing: _currentTheme == theme
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() => _currentTheme = theme);
                  _applyTheme(theme);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Handle style click to change map style
  void _showStyleOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...MapStyle.values.map((style) {
              final mapState = ref.read(mapStateProvider);
              return ListTile(
                title: Text(style.name),
                trailing: mapState.mapStyle == style
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(mapStateProvider.notifier).setMapStyle(style);
                  _mapboxMap?.loadStyleURI(style.url);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Show trip statistics
  void _showStatistics() {
    final stats = ref.read(tripStatsProvider);
    final completion = ref.read(completionPercentageProvider);

    if (stats == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Statistics not available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion
              _StatRow(label: 'Completion', value: '$completion%'),
              // Destinations
              _StatRow(
                label: 'Destinations',
                value:
                    '${stats.destinations.visited}/${stats.destinations.total}',
              ),
              const SizedBox(height: 12),
              // Distance
              _StatRow(
                label: 'Total Distance',
                value:
                    '${stats.geography.routeDistanceKm.toStringAsFixed(1)} km',
              ),
              // Area
              _StatRow(
                label: 'Coverage Area',
                value:
                    '${stats.geography.boundaryAreaKm2.toStringAsFixed(1)} km²',
              ),
              const SizedBox(height: 12),
              // Duration
              _StatRow(
                label: 'Trip Duration',
                value: stats.timeline.durationDays != null
                    ? '${stats.timeline.durationDays} days'
                    : 'N/A',
              ),
              // Visited status
              if (stats.timeline.lastVisit != null &&
                  stats.timeline.lastVisit!.isBefore(DateTime.now()))
                _StatRow(
                  label: 'Last Visit',
                  value: _formatDate(stats.timeline.lastVisit!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider);
    final isLoading = mapState.isLoading;
    final error = mapState.error;
    final completion = ref.watch(completionPercentageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(mapState.currentTrip?.name ?? '🗺️ Discover Sri Lanka'),
        actions: [
          // Theme selector
          IconButton(
            icon: Icon(
              _currentTheme == styles.MapTheme.fogOfWar
                  ? Icons.dark_mode
                  : Icons.palette,
            ),
            onPressed: _showThemeOptions,
            tooltip: 'Change map theme',
          ),
          // Style button
          IconButton(
            icon: const Icon(Icons.style),
            onPressed: _showStyleOptions,
            tooltip: 'Change map style',
          ),
          // Statistics button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStatistics,
            tooltip: 'View statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Mapbox map
                MapWidget(
                  key: const ValueKey('mapWidget'),
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(80.7718, 7.8731)),
                    zoom: 7.0,
                  ),
                  onMapCreated: _onMapCreated,
                  onStyleLoadedListener: _onStyleLoaded,
                  styleUri: mapState.mapStyle.url,
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                // Error message
                if (error != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom info panel
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Completion progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trip Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: completion / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                completion == 100 ? Colors.green : Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completion% Complete',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Layer visibility toggles
                Row(
                  children: [
                    Expanded(
                      child: _LayerToggle(
                        label: 'Route',
                        value: mapState.showRoute,
                        onChanged: (value) {
                          ref
                              .read(mapStateProvider.notifier)
                              .toggleRoute(value);
                          _mapController.setLayerVisibility(
                            'trip-route',
                            value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LayerToggle(
                        label: 'Boundary',
                        value: mapState.showBoundary,
                        onChanged: (value) {
                          ref
                              .read(mapStateProvider.notifier)
                              .toggleBoundary(value);
                          _mapController.setLayerVisibility(
                            'trip-boundary',
                            value,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Refresh button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadTripData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single statistic row
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Layer visibility toggle
class _LayerToggle extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _LayerToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? Colors.blue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: value ? Colors.blue.shade50 : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color: value ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
