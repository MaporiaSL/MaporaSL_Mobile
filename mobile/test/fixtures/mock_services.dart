// Mock service implementations for testing
import 'package:gemified_travel_portfolio/features/exploration/data/models/exploration_models.dart';

/// Mock API Service
class MockApiService {
  List<ExplorationLocation>? mockLocations;
  bool shouldFail = false;
  Duration? simulatedDelay;

  Future<List<ExplorationLocation>> fetchLocations(String district) async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }

    if (shouldFail) {
      throw Exception('API Error');
    }

    return mockLocations ?? [];
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    if (shouldFail) {
      throw Exception('API Error');
    }

    return {
      'uid': userId,
      'email': 'test@example.com',
      'displayName': 'Test User',
      'level': 1,
      'xp': 0,
    };
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (shouldFail) {
      throw Exception('API Error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVisits(String userId) async {
    if (shouldFail) {
      throw Exception('API Error');
    }
    return [];
  }

  void reset() {
    mockLocations = null;
    shouldFail = false;
    simulatedDelay = null;
  }
}

/// Mock Authentication Service
class MockAuthService {
  String? currentUserId;
  bool isAuthenticated = false;
  bool shouldFail = false;

  Future<String> signUp(String email, String password) async {
    if (shouldFail) {
      throw Exception('Sign up failed');
    }
    currentUserId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';
    isAuthenticated = true;
    return currentUserId!;
  }

  Future<String> signIn(String email, String password) async {
    if (shouldFail) {
      throw Exception('Sign in failed');
    }
    currentUserId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';
    isAuthenticated = true;
    return currentUserId!;
  }

  Future<void> signOut() async {
    currentUserId = null;
    isAuthenticated = false;
  }

  Future<void> resetPassword(String email) async {
    if (shouldFail) {
      throw Exception('Password reset failed');
    }
  }

  Future<bool> verifyEmail() async {
    return !shouldFail;
  }

  String? getCurrentUserId() => currentUserId;

  bool isUserAuthenticated() => isAuthenticated && currentUserId != null;

  void reset() {
    currentUserId = null;
    isAuthenticated = false;
    shouldFail = false;
  }
}

/// Mock Location Service
class MockLocationService {
  bool hasPermission = true;
  bool shouldFail = false;

  Future<bool> requestPermission() async {
    return hasPermission && !shouldFail;
  }

  Future<Map<String, double>> getCurrentLocation() async {
    if (shouldFail) {
      throw Exception('Location error');
    }

    if (!hasPermission) {
      throw Exception('Permission denied');
    }

    return {'latitude': 6.9271, 'longitude': 80.7789};
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    if (shouldFail) {
      throw Exception('Geocoding error');
    }
    return 'Colombo, Sri Lanka';
  }

  Stream<Map<String, double>> watchUserLocation() async* {
    for (int i = 0; i < 5; i++) {
      if (!shouldFail) {
        yield {
          'latitude': 6.9271 + (i * 0.001),
          'longitude': 80.7789 + (i * 0.001),
        };
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void reset() {
    hasPermission = true;
    shouldFail = false;
  }
}

/// Mock Storage Service
class MockStorageService {
  final Map<String, dynamic> _storage = {};
  bool shouldFail = false;

  Future<void> saveData(String key, dynamic value) async {
    if (shouldFail) {
      throw Exception('Storage error');
    }
    _storage[key] = value;
  }

  Future<dynamic> getData(String key) async {
    if (shouldFail) {
      throw Exception('Storage error');
    }
    return _storage[key];
  }

  Future<void> deleteData(String key) async {
    if (shouldFail) {
      throw Exception('Storage error');
    }
    _storage.remove(key);
  }

  Future<void> clearAll() async {
    if (shouldFail) {
      throw Exception('Storage error');
    }
    _storage.clear();
  }

  Map<String, dynamic> getAllData() => Map.from(_storage);

  void reset() {
    _storage.clear();
    shouldFail = false;
  }
}

/// Mock Notification Service
class MockNotificationService {
  List<String> sentNotifications = [];
  bool shouldFail = false;

  Future<void> showNotification(String title, String message) async {
    if (shouldFail) {
      throw Exception('Notification error');
    }
    sentNotifications.add('$title: $message');
  }

  Future<void> scheduleNotification(
    String title,
    String message,
    Duration delay,
  ) async {
    if (shouldFail) {
      throw Exception('Notification error');
    }
    await Future.delayed(delay);
    sentNotifications.add('$title: $message (scheduled)');
  }

  List<String> getNotificationHistory() => List.from(sentNotifications);

  void reset() {
    sentNotifications.clear();
    shouldFail = false;
  }
}
