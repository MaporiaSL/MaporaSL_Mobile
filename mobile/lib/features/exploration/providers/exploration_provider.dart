import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../data/exploration_api.dart';
import '../data/models/exploration_models.dart';

class ExplorationState {
  final bool isLoading;
  final bool isVerifying;
  final String? error;
  final String? verifyingLocationId;
  final List<DistrictAssignment> assignments;
  final List<DistrictSummary> districts;
  final int currentStepIndex;
  final String? verificationStep;

  const ExplorationState({
    required this.isLoading,
    required this.isVerifying,
    required this.error,
    required this.verifyingLocationId,
    required this.assignments,
    required this.districts,
    this.currentStepIndex = -1,
    this.verificationStep,
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
    int? currentStepIndex,
    String? verificationStep,
  }) {
    return ExplorationState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      verifyingLocationId: verifyingLocationId ?? this.verifyingLocationId,
      assignments: assignments ?? this.assignments,
      districts: districts ?? this.districts,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      verificationStep: verificationStep ?? this.verificationStep,
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
      error: null,
      currentStepIndex: 0,
      verificationStep: 'Initializing satellite downlink...',
    );

    String? errorMessage;
    int finalStep = 0;
    try {
      debugPrint('📍 Ensuring location permissions...');
      await _ensureLocationPermission();
      
      debugPrint('📍 Moving to Step 1: Scanning geofence');
      state = state.copyWith(currentStepIndex: 1, verificationStep: 'Scanning local geofence...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final samples = await _collectSamples();
      
      debugPrint('📍 Moving to Step 4: Final Upload');
      state = state.copyWith(currentStepIndex: 4, verificationStep: 'Uploading verification payload...');
      await _api.visitLocation(locationId: location.id, samples: samples);
      
      await loadAssignments();
      finalStep = 5;
    } catch (error) {
      debugPrint('❌ Exploration verification failed: $error');
      
      // Extract specific error message from server if available
      if (error is DioException && error.response?.data is Map) {
        final data = error.response!.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        }
      }
      errorMessage ??= error.toString().replaceAll('Exception: ', '');

      // Map failure to correct UI step
      finalStep = state.currentStepIndex;
      final lowerError = errorMessage.toLowerCase();
      
      if (lowerError.contains('permission')) {
        finalStep = 0;
      } else if (lowerError.contains('samples') || lowerError.contains('sample count')) {
        finalStep = 2; // Multi-path / Sampling step
      } else if (lowerError.contains('gps') || 
                 lowerError.contains('radius') || 
                 lowerError.contains('distance') || 
                 lowerError.contains('far') || 
                 lowerError.contains('meters') ||
                 lowerError.contains('geofence')) {
        finalStep = 1; // Boundary check step
      } else if (lowerError.contains('upload') || lowerError.contains('server')) {
        finalStep = 4; // Final upload step
      }
    } finally {
      debugPrint('🏁 Finishing exploration verification at step $finalStep');
      state = state.copyWith(
        isVerifying: false,
        verifyingLocationId: null,
        error: errorMessage,
        currentStepIndex: finalStep,
      );
    }
  }

  Future<void> _ensureLocationPermission() async {
    debugPrint('📍 Checking location services...');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 5), onTimeout: () => true);
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    debugPrint('📍 Checking location permissions...');
    var permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 5), onTimeout: () => LocationPermission.always);
    if (permission == LocationPermission.denied) {
      debugPrint('📍 Requesting location permissions...');
      permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 15), onTimeout: () => LocationPermission.denied);
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    debugPrint('📍 Permissions secured');
  }

  Future<List<LocationSample>> _collectSamples() async {
    const samplesNeeded = 3;
    const interval = Duration(seconds: 2);
    final samples = <LocationSample>[];

    for (var i = 0; i < samplesNeeded; i += 1) {
      debugPrint('📍 Collecting sample ${i+1}/$samplesNeeded...');
      // Index 2 is "Multi-Path Correction" (samples), Index 3 is "Atmospheric Validation"
      state = state.copyWith(
        currentStepIndex: i == 0 ? 1 : 2, 
        verificationStep: i == 0 ? 'Fixing boundary coordinates...' : 'Sampling multi-path signals ($i/$samplesNeeded)...'
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        debugPrint('⏳ GPS Timeout at sample ${i+1}');
        throw Exception('GPS positioning timed out. Please ensure GPS is enabled and has clear sky view.');
      });

      samples.add(
        LocationSample(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
        ),
      );

      if (i == samplesNeeded - 1) {
         state = state.copyWith(currentStepIndex: 3, verificationStep: 'Verifying atmospheric stability...');
         await Future.delayed(const Duration(milliseconds: 800));
      }

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
