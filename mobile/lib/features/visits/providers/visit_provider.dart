import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  });

  VisitState copyWith({
    bool? isVerifying,
    String? error,
    VisitModel? lastVisit,
    bool? success,
  }) {
    return VisitState(
      isVerifying: isVerifying ?? this.isVerifying,
      error: error, // Allow nulling out error
      lastVisit: lastVisit ?? this.lastVisit,
      success: success ?? this.success,
    );
  }
}

class VisitNotifier extends StateNotifier<VisitState> {
  final VisitRepository _repo;

  VisitNotifier(this._repo) : super(VisitState());

  Future<void> markVisitWithDeviceLocation(String placeId, double targetLat, double targetLng) async {
    state = state.copyWith(isVerifying: true, error: null, success: false);
    
    try {
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

      await Future.delayed(const Duration(seconds: 1)); // For animation UX

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final visit = await _repo.markVisit(
        placeId: placeId,
        latitude: position.latitude,
        longitude: position.longitude,
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
