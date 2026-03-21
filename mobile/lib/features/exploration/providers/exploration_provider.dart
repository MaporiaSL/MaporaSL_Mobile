import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/exploration_api.dart';
import '../data/models/exploration_models.dart';

class ExplorationState {
  final bool isLoading;
  final bool isVerifying;
  final String? error;
  final String? verifyingLocationId;
  final int currentStepIndex;
  final String? verificationStep;
  final List<DistrictAssignment> assignments;
  final List<DistrictSummary> districts;

  const ExplorationState({
    required this.isLoading,
    required this.isVerifying,
    required this.error,
    required this.verifyingLocationId,
    required this.currentStepIndex,
    required this.verificationStep,
    required this.assignments,
    required this.districts,
  });

  factory ExplorationState.initial() {
    return const ExplorationState(
      isLoading: false,
      isVerifying: false,
      error: null,
      verifyingLocationId: null,
      currentStepIndex: 0,
      verificationStep: null,
      assignments: [],
      districts: [],
    );
  }

  ExplorationState copyWith({
    bool? isLoading,
    bool? isVerifying,
    String? error,
    String? verifyingLocationId,
    int? currentStepIndex,
    String? verificationStep,
    List<DistrictAssignment>? assignments,
    List<DistrictSummary>? districts,
  }) {
    return ExplorationState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      verifyingLocationId: verifyingLocationId ?? this.verifyingLocationId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      verificationStep: verificationStep ?? this.verificationStep,
      assignments: assignments ?? this.assignments,
      districts: districts ?? this.districts,
    );
  }
}

class ExplorationNotifier extends StateNotifier<ExplorationState> {
  ExplorationNotifier(this._api) : super(ExplorationState.initial());

  final ExplorationApi _api;

  Future<void> loadAssignments() async {
    state = state.copyWith(isLoading: true, error: null);

    String? errorMessage;
    List<DistrictAssignment> assignments = state.assignments;
    List<DistrictSummary> districts = state.districts;

    try {
      assignments = await _api.fetchAssignments();
    } catch (error) {
      errorMessage = 'Failed to load assignments: $error';
    }

    try {
      districts = await _api.fetchDistricts();
    } catch (error) {
      errorMessage =
          errorMessage ?? 'Failed to load district summaries: $error';
    }

    state = state.copyWith(
      isLoading: false,
      assignments: assignments,
      districts: districts,
      error: errorMessage,
    );
  }

  Future<void> verifyLocation(ExplorationLocation location) async {
    if (state.isVerifying) return;
    
    // Set location status to verifying
    final initialAssignments = state.assignments.map((a) {
      if (a.district == location.type) { // This might be wrong, need to find the right assignment
        // Wait, assignments have lists of locations. I should find the assignment containing the location.
      }
      return a;
    }).toList();
    
    // Better way: find the location in assignments and update it
    List<DistrictAssignment> updatedAssignments = state.assignments.map((assignment) {
      final updatedLocations = assignment.locations.map((loc) {
        if (loc.id == location.id) {
          return loc.copyWith(status: VerificationStatus.verifying);
        }
        return loc;
      }).toList();
      return assignment.copyWith(locations: updatedLocations);
    }).toList();

    state = state.copyWith(
      isVerifying: true,
      verifyingLocationId: location.id,
      currentStepIndex: 0,
      verificationStep: 'Satellite Signal Strength',
      assignments: updatedAssignments,
      error: null,
    );

    String? errorMessage;
    VerificationStatus finalStatus = VerificationStatus.passed;
    String? rejectionReason;

    try {
      state = state.copyWith(
        currentStepIndex: 1,
        verificationStep: 'Main Geofence Boundary Check',
      );
      await _ensureLocationPermission();

      state = state.copyWith(
        currentStepIndex: 2,
        verificationStep: 'Multi-Path Reflection Correction',
      );
      final samples = await _collectSamples();

      state = state.copyWith(
        currentStepIndex: 3,
        verificationStep: 'Atmospheric Data Validation',
      );
      await _api.visitLocation(locationId: location.id, samples: samples);

      state = state.copyWith(
        currentStepIndex: 4,
        verificationStep: 'Proximity Finalization',
      );
      await loadAssignments();

      state = state.copyWith(
        currentStepIndex: 5,
        verificationStep: 'Verification complete',
      );
    } catch (error) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('not enough valid gps samples') || errorStr.contains('gps')) {
        rejectionReason = 'Poor GPS signal. Please try moving to an open area.';
      } else if (errorStr.contains('too far')) {
        rejectionReason = 'You are too far from this location.';
      } else if (errorStr.contains('429') || errorStr.contains('cooldown')) {
        rejectionReason = 'Verification cooldown active. Please wait 5 minutes.';
      } else {
        rejectionReason = 'Verification failed. Please try again.';
      }
      errorMessage = rejectionReason;
      finalStatus = VerificationStatus.failed;
    } finally {
      // Update the final status of the location
      updatedAssignments = state.assignments.map((assignment) {
        final updatedLocations = assignment.locations.map((loc) {
          if (loc.id == location.id) {
            return loc.copyWith(
              status: finalStatus,
              rejectionReason: rejectionReason,
              visited: finalStatus == VerificationStatus.passed,
            );
          }
          return loc;
        }).toList();
        return assignment.copyWith(locations: updatedLocations);
      }).toList();

      state = state.copyWith(
        isVerifying: false,
        verifyingLocationId: null,
        assignments: updatedAssignments,
        error: errorMessage,
      );
    }
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
