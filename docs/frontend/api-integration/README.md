# API Integration Guide

**For**: Flutter Frontend Developers  
**Last Updated**: February 1, 2026

---

## Overview

This guide shows how the Flutter frontend integrates with the Node.js/Express backend API, including authentication, request handling, error management, and state synchronization.

---

## Architecture

```
Flutter App
     ↓
ApiClient (Dio)
     ↓
JWT Token Injection
     ↓
Backend API (Express.js)
     ↓
MongoDB
```

---

## Setup

### 1. Dependencies

**pubspec.yaml**:
```yaml
dependencies:
  dio: ^5.3.3  # HTTP client
  flutter_secure_storage: ^9.0.0  # Secure token storage
  riverpod: ^2.4.9  # State management
```

### 2. API Client Service

**File**: `mobile/lib/core/services/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String baseUrl = 'http://localhost:5000';  // Dev
  // static const String baseUrl = 'http://10.0.2.2:5000';  // Android Emulator
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }
  
  // Attach JWT token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  // Log successful responses
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print('API Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }
  
  // Handle errors globally
  void _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    print('API Error: ${err.response?.statusCode} ${err.message}');
    
    if (err.response?.statusCode == 401) {
      // Token expired or invalid - trigger re-login
      // Navigate to login or refresh token
    }
    
    handler.next(err);
  }
  
  // GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }
  
  // POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
  }) async {
    final response = await _dio.post(path, data: data);
    return response.data;
  }
  
  // PATCH request
  Future<dynamic> patch(
    String path, {
    dynamic data,
  }) async {
    final response = await _dio.patch(path, data: data);
    return response.data;
  }
  
  // DELETE request
  Future<dynamic> delete(String path) async {
    final response = await _dio.delete(path);
    return response.data;
  }
}
```

---

## Authentication Flow

### 1. Login with Firebase Auth

```dart
// File: mobile/lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);
  
  Future<void> login(String email, String password) async {
    // 1. Firebase login
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Store ID token
    final token = await credentials.user?.getIdToken();
    if (token != null) {
      await _storage.write(key: 'access_token', value: token);
    }

    // 3. Sync user to backend
    await _apiClient.post('/api/auth/register', data: {
      'firebaseUid': credentials.user?.uid,
      'email': credentials.user?.email,
      'name': credentials.user?.displayName ?? 'Unknown',
      'profilePicture': credentials.user?.photoURL,
    });
  }
}
```

---

## API Integration Examples

### Authentication

#### Register/Sync User

```dart
final response = await apiClient.post('/api/auth/register', data: {
  'firebaseUid': 'firebase-uid-123',
  'email': 'user@example.com',
  'name': 'John Doe',
});

final user = User.fromJson(response['user']);
```

#### Get Current User

```dart
final response = await apiClient.get('/api/auth/me');
final user = User.fromJson(response);
```

---

### Trips

#### Create Trip

```dart
final response = await apiClient.post('/api/travel', data: {
  'title': 'Sri Lanka Adventure',
  'description': 'Two week island exploration',
  'startDate': DateTime(2026, 7, 1).toIso8601String(),
  'endDate': DateTime(2026, 7, 15).toIso8601String(),
});

final trip = Trip.fromJson(response);
```

#### Get All Trips

```dart
final response = await apiClient.get('/api/travel', queryParameters: {
  'limit': 20,
  'skip': 0,
});

final trips = (response['travels'] as List)
    .map((json) => Trip.fromJson(json))
    .toList();
```

#### Update Trip

```dart
final response = await apiClient.patch('/api/travel/$tripId', data: {
  'title': 'Updated Trip Title',
  'description': 'New description',
});

final updatedTrip = Trip.fromJson(response);
```

#### Delete Trip

```dart
await apiClient.delete('/api/travel/$tripId');
```

---

### Destinations

#### Add Destination to Trip

```dart
final response = await apiClient.post(
  '/api/travel/$travelId/destinations',
  data: {
    'name': 'Sigiriya Rock Fortress',
    'latitude': 7.9570,
    'longitude': 80.7603,
    'districtId': 'matale',
    'notes': 'Amazing views!',
  },
);

final destination = Destination.fromJson(response);
```

#### Get Trip Destinations

```dart
final response = await apiClient.get('/api/travel/$travelId/destinations');

final destinations = (response['destinations'] as List)
    .map((json) => Destination.fromJson(json))
    .toList();
```

#### Mark Destination as Visited

```dart
final response = await apiClient.patch(
  '/api/travel/$travelId/destinations/$destId',
  data: {'visited': true},
);
```

---

### Maps & Geospatial

#### Get Trip GeoJSON for Map

```dart
final geoJson = await apiClient.get(
  '/api/travel/$travelId/geojson',
  queryParameters: {
    'includeRoute': 'true',
    'includeBoundary': 'true',
  },
);

// Load into Mapbox
await mapController.addGeoJsonSource('trip-source', geoJson);
```

#### Find Nearby Destinations

```dart
final response = await apiClient.get('/api/destinations/nearby', queryParameters: {
  'lat': 7.8731,
  'lng': 80.7718,
  'radius': 50,  // km
});

final nearbyPlaces = (response['results'] as List)
    .map((json) => Destination.fromJson(json['destination']))
    .toList();
```

---

## Error Handling

### Global Error Handler

```dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
  
  @override
  String toString() => '$statusCode: $message';
}

// In ApiClient
void _onError(DioException err, ErrorInterceptorHandler handler) {
  String message = 'An error occurred';
  
  if (err.response != null) {
    message = err.response!.data['error'] ?? message;
  } else if (err.type == DioExceptionType.connectionTimeout) {
    message = 'Connection timeout';
  } else if (err.type == DioExceptionType.receiveTimeout) {
    message = 'Server not responding';
  }
  
  throw ApiException(err.response?.statusCode, message);
}
```

### Usage in Provider

```dart
Future<void> loadTrips() async {
  try {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await apiClient.get('/api/travel');
    final trips = (response['travels'] as List)
        .map((e) => Trip.fromJson(e))
        .toList();
    
    state = state.copyWith(trips: trips, isLoading: false);
  } on ApiException catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.message,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: 'Unexpected error occurred',
    );
  }
}
```

---

## State Management with Riverpod

### API Client Provider

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
```

### Trips Provider

```dart
class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier(this._apiClient) : super(TripsState.initial());
  
  final ApiClient _apiClient;
  
  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true);
    
    final response = await _apiClient.get('/api/travel');
    final trips = (response['travels'] as List)
        .map((e) => Trip.fromJson(e))
        .toList();
    
    state = state.copyWith(trips: trips, isLoading: false);
  }
  
  Future<void> createTrip(Trip trip) async {
    final response = await _apiClient.post('/api/travel', data: trip.toJson());
    final newTrip = Trip.fromJson(response);
    
    state = state.copyWith(
      trips: [...state.trips, newTrip],
    );
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier(ref.read(apiClientProvider));
});
```

---

## Data Models

### Example: Trip Model

```dart
class Trip {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> locations;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Trip({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.locations,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      locations: List<String>.from(json['locations'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'locations': locations,
    };
  }
}
```

---

## Testing

### Unit Test API Client

```dart
void main() {
  test('ApiClient GET request', () async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/auth/me');
    
    expect(response, isNotNull);
    expect(response['email'], isNotEmpty);
  });
}
```

### Widget Test with Mocked API

```dart
class MockApiClient extends Mock implements ApiClient {}

void main() {
  testWidgets('TripsScreen loads trips', (tester) async {
    final mockApiClient = MockApiClient();
    
    when(mockApiClient.get('/api/travel')).thenAnswer(
      (_) async => {'travels': [], 'total': 0},
    );
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: MaterialApp(home: TripsScreen()),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.text('No trips yet'), findsOneWidget);
  });
}
```

---

## Best Practices

1. **Always handle errors**: Wrap API calls in try-catch blocks
2. **Show loading states**: Set `isLoading = true` before API calls
3. **Validate data**: Check null values before accessing
4. **Use models**: Don't work with raw JSON maps
5. **Secure tokens**: Store JWT in FlutterSecureStorage, not SharedPreferences
6. **Timeout handling**: Set reasonable timeouts (10-30 seconds)
7. **Retry logic**: Implement retry for failed requests
8. **Offline support**: Cache data locally with Hive/Isar

---

## See Also

- [Auth API Endpoints](../backend/api-endpoints/auth-endpoints.md)
- [Travel API Endpoints](../backend/api-endpoints/travel-endpoints.md)
- [Authentication Implementation](../common/feature-implementation/authentication.md)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Riverpod Documentation](https://riverpod.dev)
