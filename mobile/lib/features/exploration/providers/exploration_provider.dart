import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/exploration_api.dart';
import '../data/models/exploration_models.dart';

class ExplorationState {
  final bool isLoading;
  final bool isVerifying;
  final String? error;
  final String? verifyingLocationId;
  final List<DistrictAssignment> assignments;
  final List<DistrictSummary> districts;

  const ExplorationState({
    required this.isLoading,
    required this.isVerifying,
    required this.error,
    required this.verifyingLocationId,
    required this.assignments,
    required this.districts,
  });

  factory ExplorationState.initial() {
    return const ExplorationState(
      isLoading: false,
      isVerifying: false,
      error: null,
      verifyingLocationId: null,
      assignments: [],
      districts: [],
    );
  }

  ExplorationState copyWith({
    bool? isLoading,
    bool? isVerifying,
    String? error,
    String? verifyingLocationId,
    List<DistrictAssignment>? assignments,
    List<DistrictSummary>? districts,
  }) {
    return ExplorationState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      verifyingLocationId: verifyingLocationId ?? this.verifyingLocationId,
      assignments: assignments ?? this.assignments,
      districts: districts ?? this.districts,
    );
  }
}

class ExplorationNotifier extends StateNotifier<ExplorationState> {
  ExplorationNotifier(this._api) : super(ExplorationState.initial());

  final ExplorationApi _api;

  static const bool _devSeedAssignments = true;

  Future<void> loadAssignments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      var assignments = await _api.fetchAssignments();
      var districts = await _api.fetchDistricts();
      if (_devSeedAssignments && assignments.isEmpty) {
        assignments = await _loadDevAssignmentsFromAsset();
        districts = _buildDevDistricts(assignments);
      }
      state = state.copyWith(
        isLoading: false,
        assignments: assignments,
        districts: districts,
      );
    } catch (error) {
      if (_devSeedAssignments) {
        final assignments = await _loadDevAssignmentsFromAsset();
        state = state.copyWith(
          isLoading: false,
          assignments: assignments,
          districts: _buildDevDistricts(assignments),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load exploration data',
        );
      }
    }
  }

  Future<List<DistrictAssignment>> _loadDevAssignmentsFromAsset() async {
    final raw = await rootBundle.loadString(
      'assets/data/places_seed_data_2026.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final districts = data['districts'] as List<dynamic>? ?? [];

    return districts.map((entry) {
      final districtData = Map<String, dynamic>.from(entry as Map);
      final district = districtData['district']?.toString() ?? '';
      final province = districtData['province']?.toString() ?? 'Unknown';
      final attractions =
          districtData['attractions'] as List<dynamic>? ?? [];
      final locations = attractions.asMap().entries.map((item) {
        final index = item.key;
        final attraction = Map<String, dynamic>.from(item.value as Map);
        final visited = district == 'Colombo' && index == 0;
        return ExplorationLocation(
          id: 'seed-${district.toLowerCase().replaceAll(' ', '-')}-${index + 1}',
          name: attraction['name']?.toString() ?? 'Unknown Place',
          type: attraction['type']?.toString() ?? 'Unknown',
          latitude: (attraction['lat'] as num?)?.toDouble() ?? 0,
          longitude: (attraction['lon'] as num?)?.toDouble() ?? 0,
          visited: visited,
        );
      }).toList();

      final visitedCount = locations.where((loc) => loc.visited).length;
      final assignedCount = locations.length;
      return DistrictAssignment(
        district: district,
        province: province,
        assignedCount: assignedCount,
        visitedCount: visitedCount,
        unlockedAt:
            visitedCount >= assignedCount ? DateTime.now() : null,
        locations: locations,
      );
    }).toList();
  }

  List<DistrictSummary> _buildDevDistricts(
    List<DistrictAssignment> assignments,
  ) {
    return assignments
        .map(
          (assignment) => DistrictSummary(
            district: assignment.district,
            province: assignment.province,
            assignedCount: assignment.assignedCount,
            visitedCount: assignment.visitedCount,
            unlockedAt: assignment.unlockedAt,
          ),
        )
        .toList();
  }

  Future<void> verifyLocation(ExplorationLocation location) async {
    if (state.isVerifying) return;
    state = state.copyWith(
      isVerifying: true,
      verifyingLocationId: location.id,
      error: null,
    );

    try {
      if (_devSeedAssignments) {
        _markVisitedLocally(location.id);
      } else {
        await _ensureLocationPermission();
        final samples = await _collectSamples();
        await _api.visitLocation(locationId: location.id, samples: samples);
        await loadAssignments();
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      state = state.copyWith(isVerifying: false, verifyingLocationId: null);
    }
  }

  void _markVisitedLocally(String locationId) {
    final updatedAssignments = state.assignments.map((assignment) {
      var updated = false;
      final updatedLocations = assignment.locations.map((location) {
        if (location.id == locationId && !location.visited) {
          updated = true;
          return ExplorationLocation(
            id: location.id,
            name: location.name,
            type: location.type,
            latitude: location.latitude,
            longitude: location.longitude,
            visited: true,
          );
        }
        return location;
      }).toList();

      if (!updated) {
        return assignment;
      }

      final visitedCount = updatedLocations.where((loc) => loc.visited).length;
      final assignedCount = updatedLocations.length;
      return DistrictAssignment(
        district: assignment.district,
        province: assignment.province,
        assignedCount: assignedCount,
        visitedCount: visitedCount,
        unlockedAt:
            visitedCount >= assignedCount ? DateTime.now() : assignment.unlockedAt,
        locations: updatedLocations,
      );
    }).toList();

    state = state.copyWith(
      assignments: updatedAssignments,
      districts: _buildDevDistricts(updatedAssignments),
    );
  }

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
  }

  Future<List<LocationSample>> _collectSamples() async {
    const samplesNeeded = 3;
    const interval = Duration(seconds: 2);
    final samples = <LocationSample>[];

    for (var i = 0; i < samplesNeeded; i += 1) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      samples.add(
        LocationSample(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
        ),
      );
      if (i < samplesNeeded - 1) {
        await Future.delayed(interval);
      }
    }

    return samples;
  }
}

final explorationProvider =
    StateNotifierProvider<ExplorationNotifier, ExplorationState>((ref) {
  return ExplorationNotifier(ExplorationApi());
});
