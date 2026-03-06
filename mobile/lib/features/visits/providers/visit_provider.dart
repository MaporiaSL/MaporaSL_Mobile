import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_config.dart';
import '../data/visit_repository.dart';
import '../data/models/visit_model.dart';
import '../../Auth/providers/auth_provider.dart';

final visitDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${AppConfig.apiBaseUrl}/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('>>> [VISITS DIO] REQUEST TO: ${options.uri.toString()}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('>>> [VISITS DIO] RESPONSE: ${response.statusCode}');
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      print('>>> [VISITS DIO] ERROR: ${e.response?.statusCode} AT ${e.requestOptions.uri.toString()}');
      print('>>> [VISITS DIO] ERROR DATA: ${e.response?.data}');
      return handler.next(e);
    }
  ));
  
  return dio;
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final dio = ref.watch(visitDioProvider);
  final authState = ref.watch(authProvider);
  return VisitRepository(dio, authState.token);
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
