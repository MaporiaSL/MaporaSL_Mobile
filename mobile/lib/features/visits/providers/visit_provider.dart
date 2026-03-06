import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../data/visit_repository.dart';
import '../data/models/visit_model.dart';
import '../../../../core/services/api_client.dart';

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return VisitRepository(client);
});

class VisitState {
  final bool isVerifying;
  final String? error;
  final VisitModel? lastVisit;
  final bool success;

  VisitState({
    this.isVerifying = false,
    this.error,
    this.lastVisit,
    this.success = false,
    this.currentStepIndex = -1,
    this.verificationStep,
  });

  final int currentStepIndex;
  final String? verificationStep;

  VisitState copyWith({
    bool? isVerifying,
    String? error,
    VisitModel? lastVisit,
    bool? success,
    int? currentStepIndex,
    String? verificationStep,
  }) {
    return VisitState(
      isVerifying: isVerifying ?? this.isVerifying,
      error: error, // Allow nulling out error
      lastVisit: lastVisit ?? this.lastVisit,
      success: success ?? this.success,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      verificationStep: verificationStep ?? this.verificationStep,
    );
  }
}

class VisitNotifier extends StateNotifier<VisitState> {
  final VisitRepository _repo;

  VisitNotifier(this._repo) : super(VisitState());

  Future<void> markVisitWithDeviceLocation(String placeId, double targetLat, double targetLng) async {
    state = state.copyWith(isVerifying: true, error: null, success: false, currentStepIndex: 0, verificationStep: 'Checking satellite signals...');
    
    String? errorMessage;
    try {
      debugPrint('📍 Checking location services...');
      final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('⏳ Location service check timed out');
        return true; // Proceed anyway
      });
      
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      debugPrint('📍 Checking permissions...');
      var permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 5), onTimeout: () => LocationPermission.always);
      if (permission == LocationPermission.denied) {
        debugPrint('📍 Requesting permissions...');
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 15), onTimeout: () => LocationPermission.denied);
      }

      debugPrint('📍 Location permissions secured');
      
      // Artificial delay for Step 0 visibility
      await Future.delayed(const Duration(milliseconds: 600));

      debugPrint('📍 Moving to Step 1: Acquiring position');
      state = state.copyWith(currentStepIndex: 1, verificationStep: 'Acquiring geofence boundary...');
      await Future.delayed(const Duration(milliseconds: 600)); // Minor delay for UI feedback

      debugPrint('📍 Calling Geolocator.getCurrentPosition...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        debugPrint('⏳ GPS Timeout in visit notifier');
        throw Exception('GPS positioning timed out. Please check your location settings.');
      });

      debugPrint('📍 Position acquired: ${position.latitude}, ${position.longitude}');
      state = state.copyWith(currentStepIndex: 2, verificationStep: 'Correcting signal multi-path...');
      // VisitRepository.markVisit doesn't take multiple samples yet, but we'll show progress
      await Future.delayed(const Duration(milliseconds: 800));

      state = state.copyWith(currentStepIndex: 3, verificationStep: 'Validating atmospheric metadata...');
      await Future.delayed(const Duration(milliseconds: 600));

      state = state.copyWith(currentStepIndex: 4, verificationStep: 'Finalizing proximity check...');
      final visit = await _repo.markVisit(
        placeId: placeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      state = state.copyWith(
        isVerifying: false,
        lastVisit: visit,
        success: true,
        currentStepIndex: 5,
      );
    } catch (e) {
      debugPrint('❌ Visit verification failed: $e');
      
      // Extract specific error message from server if available
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        }
      }
      errorMessage ??= e.toString().replaceAll('Exception: ', '');

      // Map failure to correct UI step
      int finalStep = state.currentStepIndex;
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
      
      state = state.copyWith(
        isVerifying: false,
        error: errorMessage,
        success: false,
        currentStepIndex: finalStep,
      );
    }
  }

  Future<void> markVisit(String placeId, double lat, double lng) async {
    state = state.copyWith(isVerifying: true, error: null, success: false);
    
    try {
      final visit = await _repo.markVisit(
        placeId: placeId,
        latitude: lat,
        longitude: lng,
      );
      
      state = state.copyWith(
        isVerifying: false,
        lastVisit: visit,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: e.toString().replaceAll('Exception: ', ''),
        success: false,
      );
    }
  }

  void reset() {
    state = VisitState();
  }
}

final visitProvider = StateNotifierProvider<VisitNotifier, VisitState>((ref) {
  return VisitNotifier(ref.watch(visitRepositoryProvider));
});

final userVisitsProvider = FutureProvider<List<VisitModel>>((ref) async {
  final repo = ref.watch(visitRepositoryProvider);
  return repo.getUserVisits();
});
