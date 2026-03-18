/// Test fixtures and mock data generators
import 'package:gemified_travel_portfolio/features/exploration/data/models/exploration_models.dart';
import 'package:gemified_travel_portfolio/features/visits/data/models/visit_models.dart';

/// Mock data factory for testing
class TestDataFactory {
  /// Create mock location
  static ExplorationLocation createMockLocation({
    String id = 'test-location-1',
    String name = 'Test Location',
    double latitude = 6.9271,
    double longitude = 80.7789,
    String district = 'Colombo',
    bool visited = false,
  }) {
    return ExplorationLocation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      district: district,
      description: 'Test location description',
      imageUrl: 'https://example.com/image.jpg',
      visited: visited,
      category: 'Cultural',
      difficulty: 'Easy',
    );
  }

  /// Create mock visit
  static VisitModel createMockVisit({
    String id = 'test-visit-1',
    String placeId = 'test-place-1',
    String placeName = 'Test Place',
    DateTime? visitDate,
    double rating = 4.5,
    String? notes,
    String status = 'completed',
  }) {
    return VisitModel(
      id: id,
      placeId: placeId,
      placeName: placeName,
      visitDate: visitDate ?? DateTime.now(),
      rating: rating,
      notes: notes ?? 'Test visit notes',
      status: status,
      duration: 120,
      cost: 0,
    );
  }

  /// Create mock user
  static Map<String, dynamic> createMockUser({
    String uid = 'test-user-1',
    String email = 'test@example.com',
    String displayName = 'Test User',
    int level = 1,
    int xp = 0,
    int totalVisits = 0,
  }) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'level': level,
      'xp': xp,
      'totalVisits': totalVisits,
      'joinedDate': DateTime.now().toIso8601String(),
      'bio': 'Test bio',
      'profileImageUrl': 'https://example.com/profile.jpg',
    };
  }

  /// Create mock locations list
  static List<ExplorationLocation> createMockLocationsList({int count = 5}) {
    return List.generate(
      count,
      (index) =>
          createMockLocation(id: 'location-$index', name: 'Location $index'),
    );
  }

  /// Create mock visits list
  static List<VisitModel> createMockVisitsList({int count = 5}) {
    return List.generate(
      count,
      (index) => createMockVisit(
        id: 'visit-$index',
        placeId: 'place-$index',
        placeName: 'Place $index',
      ),
    );
  }
}

/// Mock API responses
class MockApiResponses {
  static Map<String, dynamic> mockLocationsResponse() {
    return {
      'locations': [
        {
          'id': 'loc-1',
          'name': 'Colombo National Museum',
          'latitude': 6.9271,
          'longitude': 80.7789,
          'district': 'Colombo',
        },
        {
          'id': 'loc-2',
          'name': 'Galle Face Hotel',
          'latitude': 6.9271,
          'longitude': 80.7789,
          'district': 'Colombo',
        },
      ],
    };
  }

  static Map<String, dynamic> mockUserResponse() {
    return {
      'uid': 'user-1',
      'email': 'user@example.com',
      'displayName': 'Test User',
      'level': 1,
      'xp': 0,
    };
  }

  static Map<String, dynamic> mockAchievementsResponse() {
    return {
      'achievements': [
        {
          'id': 'ach-1',
          'name': 'First Visit',
          'description': 'Visit your first location',
          'unlocked': true,
        },
        {
          'id': 'ach-2',
          'name': 'District Master',
          'description': 'Complete all locations in a district',
          'unlocked': false,
        },
      ],
    };
  }
}

/// Mock error responses
class MockErrorResponses {
  static Map<String, dynamic> mockNetworkError() {
    return {
      'error': 'Network error',
      'message': 'Failed to connect to server',
      'code': 'NETWORK_ERROR',
    };
  }

  static Map<String, dynamic> mockAuthError() {
    return {
      'error': 'Unauthorized',
      'message': 'Invalid credentials',
      'code': 'AUTH_ERROR',
    };
  }

  static Map<String, dynamic> mockValidationError() {
    return {
      'error': 'Validation error',
      'message': 'Invalid input',
      'code': 'VALIDATION_ERROR',
      'details': {
        'email': 'Invalid email format',
        'password': 'Password too short',
      },
    };
  }
}
