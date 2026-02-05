import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/map_models.dart';

/// Manages Mapbox map instance and layer interactions
class MapController {
  MapboxMap? _mapboxMap;
  final List<String> _activeLayers = [];
  final List<String> _activeSources = [];

  /// Initialize with MapboxMap instance
  void initialize(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  /// Get the underlying Mapbox map instance
  MapboxMap? get mapboxMap => _mapboxMap;

  /// Check if map is initialized
  bool get isInitialized => _mapboxMap != null;

  /// Load GeoJSON from trip API response
  Future<void> loadTripGeoJson(
    TripGeoJson geoJson, {
    String sourceId = 'trip-source',
    bool showRoute = true,
    bool showBoundary = true,
    bool fitBounds = true,
  }) async {
    if (_mapboxMap == null) return;

    try {
      // Convert GeoJSON to raw data
      final geoJsonData = geoJson.toJson();

      // Add GeoJSON source
      await addGeoJsonSource(sourceId, geoJsonData);

      // Add destination markers layer
      await addSymbolLayer(
        sourceId: sourceId,
        layerId: 'trip-destinations',
        filter: [
          '!=',
          ['get', 'type'],
          'route',
        ],
      );

      // Add route line layer if included
      if (showRoute) {
        await addLineLayer(
          sourceId: sourceId,
          layerId: 'trip-route',
          filter: [
            '==',
            ['get', 'type'],
            'route',
          ],
          lineColor: '#8b5cf6',
          lineWidth: 3.0,
        );
      }

      // Add boundary polygon layer if included
      if (showBoundary) {
        await addFillLayer(
          sourceId: sourceId,
          layerId: 'trip-boundary',
          filter: [
            '==',
            ['get', 'type'],
            'boundary',
          ],
          fillColor: '#8b5cf6',
          fillOpacity: 0.1,
        );
      }

      // Fit camera to bounds if requested
      if (fitBounds && geoJson.properties.destinationCount >= 2) {
        // Calculate bounds from features
        double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

        for (var feature in geoJson.features) {
          final geometry = feature['geometry'] as Map<String, dynamic>;
          if (geometry['type'] == 'Point') {
            final coords = geometry['coordinates'] as List;
            final lng = coords[0] as double;
            final lat = coords[1] as double;
            minLat = lat < minLat ? lat : minLat;
            maxLat = lat > maxLat ? lat : maxLat;
            minLng = lng < minLng ? lng : minLng;
            maxLng = lng > maxLng ? lng : maxLng;
          }
        }

        // Add padding to bounds
        const padding = 0.2;
        minLat -= padding;
        maxLat += padding;
        minLng -= padding;
        maxLng += padding;

        final bounds = CoordinateBounds(
          southwest: Point(coordinates: Position(minLng, minLat)),
          northeast: Point(coordinates: Position(maxLng, maxLat)),
        );

        await fitBounds(bounds);
      }
    } catch (e) {
      debugPrint('Error loading trip GeoJSON: $e');
    }
  }

  /// Add GeoJSON source to map
  Future<void> addGeoJsonSource(
    String sourceId,
    Map<String, dynamic> geoJson,
  ) async {
    if (_mapboxMap == null) return;

    try {
      // Remove existing source if present
      if (_activeSources.contains(sourceId)) {
        await removeSource(sourceId);
      }

      // Create GeoJsonSource from data
      final source = GeoJsonSource(id: sourceId, data: geoJson);

      // Add source to map
      await _mapboxMap!.style.addSource(source);
      _activeSources.add(sourceId);

      debugPrint('✅ Added GeoJSON source: $sourceId');
    } catch (e) {
      debugPrint('❌ Error adding GeoJSON source: $e');
    }
  }

  /// Add symbol layer for markers
  Future<void> addSymbolLayer({
    required String sourceId,
    required String layerId,
    List<dynamic>? filter,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final layer = SymbolLayer(
        id: layerId,
        sourceId: sourceId,
        iconImage: 'marker-15',
        iconSize: 1.5,
        iconColor: [
          'match',
          ['get', 'visited'],
          true,
          '#10b981',
          '#ef4444',
        ],
        textField: ['get', 'name'],
        textSize: 12.0,
        textColor: '#333333',
        textOffset: [0.0, 1.5],
        filter: filter,
      );

      await _mapboxMap!.style.addLayer(layer);
      _activeLayers.add(layerId);

      debugPrint('✅ Added symbol layer: $layerId');
    } catch (e) {
      debugPrint('❌ Error adding symbol layer: $e');
    }
  }

  /// Add line layer for routes
  Future<void> addLineLayer({
    required String sourceId,
    required String layerId,
    List<dynamic>? filter,
    String lineColor = '#8b5cf6',
    double lineWidth = 2.0,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final layer = LineLayer(
        id: layerId,
        sourceId: sourceId,
        lineColor: lineColor,
        lineWidth: lineWidth,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
        filter: filter,
      );

      await _mapboxMap!.style.addLayer(layer);
      _activeLayers.add(layerId);

      debugPrint('✅ Added line layer: $layerId');
    } catch (e) {
      debugPrint('❌ Error adding line layer: $e');
    }
  }

  /// Add fill layer for boundaries/polygons
  Future<void> addFillLayer({
    required String sourceId,
    required String layerId,
    List<dynamic>? filter,
    String fillColor = '#8b5cf6',
    double fillOpacity = 0.3,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final layer = FillLayer(
        id: layerId,
        sourceId: sourceId,
        fillColor: fillColor,
        fillOpacity: fillOpacity,
        filter: filter,
      );

      await _mapboxMap!.style.addLayer(layer);
      _activeLayers.add(layerId);

      debugPrint('✅ Added fill layer: $layerId');
    } catch (e) {
      debugPrint('❌ Error adding fill layer: $e');
    }
  }

  /// Remove layer from map
  Future<void> removeLayer(String layerId) async {
    if (_mapboxMap == null) return;

    try {
      await _mapboxMap!.style.removeLayer(layerId);
      _activeLayers.remove(layerId);
      debugPrint('✅ Removed layer: $layerId');
    } catch (e) {
      debugPrint('❌ Error removing layer: $e');
    }
  }

  /// Remove source from map
  Future<void> removeSource(String sourceId) async {
    if (_mapboxMap == null) return;

    try {
      // Remove all layers using this source first
      final layersToRemove = _activeLayers
          .where((layerId) => layerId.contains(sourceId))
          .toList();

      for (final layerId in layersToRemove) {
        await removeLayer(layerId);
      }

      // Remove the source
      await _mapboxMap!.style.removeSource(sourceId);
      _activeSources.remove(sourceId);
      debugPrint('✅ Removed source: $sourceId');
    } catch (e) {
      debugPrint('❌ Error removing source: $e');
    }
  }

  /// Update source data (for animation or refresh)
  Future<void> updateGeoJsonSource(
    String sourceId,
    Map<String, dynamic> geoJson,
  ) async {
    if (_mapboxMap == null) return;

    try {
      final source = GeoJsonSource(id: sourceId, data: geoJson);

      await _mapboxMap!.style.updateSource(source);
      debugPrint('✅ Updated GeoJSON source: $sourceId');
    } catch (e) {
      debugPrint('❌ Error updating GeoJSON source: $e');
    }
  }

  /// Fit map bounds with optional padding
  Future<void> fitBounds(
    CoordinateBounds bounds, {
    EdgeInsets padding = const EdgeInsets.all(100),
    int duration = 1000,
  }) async {
    if (_mapboxMap == null) return;

    try {
      final options = CameraOptions(bounds: bounds, padding: padding);

      await _mapboxMap!.setCamera(options);
      debugPrint('✅ Fitted camera to bounds');
    } catch (e) {
      debugPrint('❌ Error fitting bounds: $e');
    }
  }

  /// Pan to specific location
  Future<void> panTo(double latitude, double longitude) async {
    if (_mapboxMap == null) return;

    try {
      final options = CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
      );

      await _mapboxMap!.setCamera(options);
      debugPrint('✅ Panned to: $latitude, $longitude');
    } catch (e) {
      debugPrint('❌ Error panning: $e');
    }
  }

  /// Set camera zoom level
  Future<void> setZoom(double zoom) async {
    if (_mapboxMap == null) return;

    try {
      final options = CameraOptions(zoom: zoom);
      await _mapboxMap!.setCamera(options);
      debugPrint('✅ Set zoom to: $zoom');
    } catch (e) {
      debugPrint('❌ Error setting zoom: $e');
    }
  }

  /// Get current camera position
  Future<CameraState?> getCameraPosition() async {
    if (_mapboxMap == null) return null;

    try {
      return await _mapboxMap!.getCameraState();
    } catch (e) {
      debugPrint('❌ Error getting camera position: $e');
      return null;
    }
  }

  /// Enable/disable layer visibility
  Future<void> setLayerVisibility(String layerId, bool visible) async {
    if (_mapboxMap == null || !_activeLayers.contains(layerId)) return;

    try {
      final visibility = visible ? Visibility.VISIBLE : Visibility.NONE;
      await _mapboxMap!.style.setLayerProperty(
        layerId,
        'visibility',
        visibility,
      );
      debugPrint('✅ Set $layerId visibility to: $visible');
    } catch (e) {
      debugPrint('❌ Error setting layer visibility: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _mapboxMap = null;
    _activeLayers.clear();
    _activeSources.clear();
  }

  /// Get all active layer IDs
  List<String> get activeLayers => List.from(_activeLayers);

  /// Get all active source IDs
  List<String> get activeSources => List.from(_activeSources);
}
