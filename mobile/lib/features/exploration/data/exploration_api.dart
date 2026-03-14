import 'package:flutter/foundation.dart';

import '../../../core/services/api_client.dart';
import 'models/exploration_models.dart';

class ExplorationApi {
  final ApiClient _client;

  ExplorationApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<DistrictAssignment>> fetchAssignments() async {
    try {
      final response = await _client.get('/api/exploration/assignments');
      final data = response.data as Map<String, dynamic>;
      final list = data['assignments'] as List<dynamic>? ?? [];
      return list
          .map(
            (entry) => DistrictAssignment.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } catch (e) {
      // Development fallback: Return sample data if API fails
      // This helps test the UI/UX even without backend
      debugPrint('⚠️ Failed to fetch assignments from API: $e');
      return _generateSampleAssignmentsForDevelopment();
    }
  }

  /// Development helper: Generate sample exploration assignments for UI testing
  /// Includes locations with mix of visited and unvisited for fog of war testing
  List<DistrictAssignment> _generateSampleAssignmentsForDevelopment() {
    // Create sample locations for Colombo district
    final colomboLocations = [
      ExplorationLocation(
        id: 'loc-001',
        name: 'Colombo Fort Railway Station',
        type: 'Historic Railway',
        latitude: 6.9271,
        longitude: 79.8493,
        visited: true, // ✅ Visited location (green marker)
        description: 'Historic railway station built during colonial period',
        category: 'monument',
        photos: [],
      ),
      ExplorationLocation(
        id: 'loc-002',
        name: 'National Museum Colombo',
        type: 'Museum',
        latitude: 6.9217,
        longitude: 79.8581,
        visited: true, // ✅ Visited location (green marker)
        description: 'Sri Lanka\'s premier museum with extensive collections',
        category: 'museum',
        photos: [],
      ),
      ExplorationLocation(
        id: 'loc-003',
        name: 'Galle Face Hotel',
        type: 'Historic Hotel',
        latitude: 6.9271,
        longitude: 79.8400,
        visited: false, // ❌ Unvisited location (red marker - fog of war)
        description:
            'Iconic 5-star colonial hotel overlooking the Indian Ocean',
        category: 'hotel',
        photos: [],
      ),
      ExplorationLocation(
        id: 'loc-004',
        name: 'Colombo Port Authority (Jetty)',
        type: 'Port',
        latitude: 6.9300,
        longitude: 79.8467,
        visited: false, // ❌ Unvisited location (red marker - fog of war)
        description: 'Working port and maritime gateway to Colombo',
        category: 'port',
        photos: [],
      ),
      ExplorationLocation(
        id: 'loc-005',
        name: 'Colombo Central Bus Transport Board',
        type: 'Transport',
        latitude: 6.9330,
        longitude: 79.8410,
        visited: true, // ✅ Visited location (green marker)
        description: 'Main bus terminal with routes across Sri Lanka',
        category: 'transport',
        photos: [],
      ),
    ];

    return [
      DistrictAssignment(
        district: 'Colombo',
        province: 'Western',
        assignedCount: colomboLocations.length,
        visitedCount: colomboLocations
            .where((l) => l.visited)
            .length, // 3 visited
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        isUnlocked: true,
        center: const GeoPoint(latitude: 6.9271, longitude: 79.8493),
        bounds: const GeoBounds(
          minLat: 6.8800,
          maxLat: 6.9700,
          minLng: 79.8200,
          maxLng: 79.8700,
        ),
        locations: colomboLocations,
      ),
    ];
  }

  Future<List<DistrictSummary>> fetchDistricts() async {
    final response = await _client.get('/api/exploration/districts');
    final data = response.data as Map<String, dynamic>;
    final list = data['districts'] as List<dynamic>? ?? [];
    return list
        .map(
          (entry) =>
              DistrictSummary.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<void> visitLocation({
    required String locationId,
    required List<LocationSample> samples,
  }) async {
    await _client.post(
      '/api/exploration/visit',
      data: {
        'locationId': locationId,
        'samples': samples.map((sample) => sample.toJson()).toList(),
      },
    );
  }

  Future<void> rerollAssignments({
    required String reason,
    String? reasonDetail,
  }) async {
    await _client.post(
      '/api/exploration/reroll',
      data: {
        'reason': reason,
        if (reasonDetail != null) 'reasonDetail': reasonDetail,
      },
    );
  }
}
