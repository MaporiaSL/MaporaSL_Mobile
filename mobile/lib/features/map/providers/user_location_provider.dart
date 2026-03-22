import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Represents user's current location
class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calculate distance in meters to a coordinate (Haversine formula)
  double distanceToMeters(double targetLat, double targetLng) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(targetLat - latitude);
    final dLng = _toRadians(targetLng - longitude);
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(targetLat)) *
            (math.sin(dLng / 2) * math.sin(dLng / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * 0.017453292519943295;
  }
}

/// Represents user location state during tracking
class UserLocationState {
  final UserLocation? location;
  final bool isTracking;
  final bool hasPermission;
  final String? error;
  final bool isLoading;

  const UserLocationState({
    this.location,
    this.isTracking = false,
    this.hasPermission = false,
    this.error,
    this.isLoading = false,
  });

  UserLocationState copyWith({
    UserLocation? location,
    bool? isTracking,
    bool? hasPermission,
    String? error,
    bool? isLoading,
  }) {
    return UserLocationState(
      location: location ?? this.location,
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for user location state management
class UserLocationNotifier extends StateNotifier<UserLocationState> {
  UserLocationNotifier() : super(const UserLocationState());

  /// Start tracking user location in real-time
  Future<void> startTracking() async {
    if (state.isTracking) return;

    state = state.copyWith(isLoading: true);

    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          error: 'Location service is disabled',
          isLoading: false,
        );
        return;
      }

      // Check and request permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          error: 'Location permission denied',
          isLoading: false,
          hasPermission: false,
        );
        return;
      }

      state = state.copyWith(hasPermission: true);

      /// Get current position
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        location: UserLocation(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
          accuracy: currentPosition.accuracy,
        ),
        isTracking: true,
        isLoading: false,
        error: null,
      );

      /// Listen to position stream for updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 25, // Update when moved 25 meters
        ),
      ).listen(
        (position) {
          state = state.copyWith(
            location: UserLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
            ),
            isTracking: true,
            error: null,
          );
        },
        onError: (error) {
          state = state.copyWith(error: error.toString(), isTracking: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isTracking: false,
        isLoading: false,
      );
    }
  }

  /// Stop tracking user location
  void stopTracking() {
    state = state.copyWith(isTracking: false);
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Global provider for user location
final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, UserLocationState>(
      (ref) => UserLocationNotifier(),
    );
