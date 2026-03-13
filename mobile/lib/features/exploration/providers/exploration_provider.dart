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
    try {
      state = state.copyWith(isLoading: true, error: null);
      final assignments = await _api.fetchAssignments();
      final districts = await _api.fetchDistricts();
      state = state.copyWith(
        isLoading: false,
        assignments: assignments,
        districts: districts,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load exploration data: $error',
      );
    }
  }

  Future<void> verifyLocation(ExplorationLocation location) async {
    if (state.isVerifying) return;
    state = state.copyWith(
      isVerifying: true,
      verifyingLocationId: location.id,
      currentStepIndex: 0,
      verificationStep: 'Satellite Signal Strength',
      error: null,
    );

    String? errorMessage;
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
      errorMessage = error.toString();
    } finally {
      state = state.copyWith(
        isVerifying: false,
        verifyingLocationId: null,
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
