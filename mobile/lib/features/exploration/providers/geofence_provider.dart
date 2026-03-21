import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Geofence notifier for proximity-based place alerts
/// Monitors user location against assigned exploration locations
/// Sends push notifications when user enters geofence radius

class GeofenceNotifier extends StateNotifier<GeofenceState> {
  GeofenceNotifier() : super(const GeofenceState());

  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _notifiedLocationIds = {};

  /// Start monitoring user location against assigned locations
  Future<void> startMonitoring(
    List<ExplorationLocationWithDistrict> locations,
  ) async {
    // Request permissions
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(error: 'Location services are disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(error: 'Location permission denied');
      return;
    }

    // Cancel existing subscription
    await _positionSubscription?.cancel();

    // Start position stream
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50, // Update every 50 meters
          ),
        ).listen((position) {
          _checkProximity(position, locations);
        });

    state = state.copyWith(isMonitoring: true, error: null);
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(isMonitoring: false);
  }

  /// Check if user is within geofence of any location
  void _checkProximity(
    Position userPosition,
    List<ExplorationLocationWithDistrict> locations,
  ) {
    for (final location in locations) {
      final distance = _calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        location.latitude,
        location.longitude,
      );

      // Define geofence radius (500m as per user request)
      const geofenceRadius = 500.0; // meters

      if (distance < geofenceRadius) {
        // User entered geofence!
        if (!_notifiedLocationIds.contains(location.id)) {
          _notifiedLocationIds.add(location.id);
          _sendProximityNotification(location: location, distance: distance);

          // Update state
          state = state.copyWith(
            nearbyLocations: [
              ...state.nearbyLocations,
              NearbyLocation(
                locationId: location.id,
                locationName: location.name,
                districtName: location.districtName,
                distanceMeters: distance,
                xpReward: location.tier == 'sameDistrict'
                    ? 10
                    : location.tier == 'sameProvince'
                    ? 12
                    : 15,
              ),
            ],
          );
        }
      } else {
        // User left geofence
        _notifiedLocationIds.remove(location.id);
        state = state.copyWith(
          nearbyLocations: state.nearbyLocations
              .where((loc) => loc.locationId != location.id)
              .toList(),
        );
      }
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Send proximity notification
  Future<void> _sendProximityNotification({
    required ExplorationLocationWithDistrict location,
    required double distance,
  }) async {
    final xpReward = location.tier == 'sameDistrict'
        ? 10
        : location.tier == 'sameProvince'
        ? 12
        : 15;

    const channelId = 'proximity_alerts';
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Proximity Alerts',
      channelDescription:
          'Notifications when you are near exploration locations',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('digital_chime'),
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      largeIcon: const DrawableResourceAndroidBitmap('notification_icon'),
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'proximity',
      sound: 'digital_chime.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _flutterLocalNotificationsPlugin.show(
      location.id.hashCode,
      '📍 You\'re Near ${location.name}!',
      'Stop by to earn $xpReward XP and unlock ${location.districtName}.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}

// Single instance of notifications plugin
final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class GeofenceState {
  final bool isMonitoring;
  final List<NearbyLocation> nearbyLocations;
  final String? error;

  const GeofenceState({
    this.isMonitoring = false,
    this.nearbyLocations = const [],
    this.error,
  });

  GeofenceState copyWith({
    bool? isMonitoring,
    List<NearbyLocation>? nearbyLocations,
    String? error,
  }) {
    return GeofenceState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      nearbyLocations: nearbyLocations ?? this.nearbyLocations,
      error: error,
    );
  }
}

class NearbyLocation {
  final String locationId;
  final String locationName;
  final String districtName;
  final double distanceMeters;
  final int xpReward;

  NearbyLocation({
    required this.locationId,
    required this.locationName,
    required this.districtName,
    required this.distanceMeters,
    required this.xpReward,
  });
}

class ExplorationLocationWithDistrict {
  final String id;
  final String name;
  final String districtName;
  final double latitude;
  final double longitude;
  final String tier; // sameDistrict, sameProvince, otherProvince
  final bool visited;

  ExplorationLocationWithDistrict({
    required this.id,
    required this.name,
    required this.districtName,
    required this.latitude,
    required this.longitude,
    required this.tier,
    required this.visited,
  });
}

/// Geofence provider
final geofenceProvider = StateNotifierProvider<GeofenceNotifier, GeofenceState>(
  (ref) {
    return GeofenceNotifier();
  },
);

/// Initialize local notifications for geofencing alerts
Future<void> initializeGeofencingNotifications() async {
  const androidSettings = AndroidInitializationSettings('notification_icon');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await _flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );
}
