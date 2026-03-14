import 'package:freezed_annotation/freezed_annotation.dart';

part 'district_assignment_model.freezed.dart';
part 'district_assignment_model.g.dart';

/// Represents the assignment data for a single district in the exploration system
@freezed
class DistrictAssignment with _$DistrictAssignment {
  factory DistrictAssignment({
    required String district,
    required String province,
    required int assignedCount,
    required int visitedCount,
    required List<ExplorationLocation> locations,
    required CoordinateBounds bounds,
    Coordinates? center,
  }) = _DistrictAssignment;

  factory DistrictAssignment.fromJson(Map<String, dynamic> json) =>
      _$DistrictAssignmentFromJson(json);
}

/// Geographic location of an assigned exploration place
@freezed
class ExplorationLocation with _$ExplorationLocation {
  factory ExplorationLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String type,
    @Default('') String description,
    @Default([]) List<String> photos,
    @Default(false) bool visited,
  }) = _ExplorationLocation;

  factory ExplorationLocation.fromJson(Map<String, dynamic> json) =>
      _$ExplorationLocationFromJson(json);
}

/// Bounding box for a geographic region
@freezed
class CoordinateBounds with _$CoordinateBounds {
  factory CoordinateBounds({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
  }) = _CoordinateBounds;

  factory CoordinateBounds.fromJson(Map<String, dynamic> json) =>
      _$CoordinateBoundsFromJson(json);
}

/// A single geographic coordinate point
@freezed
class Coordinates with _$Coordinates {
  factory Coordinates({
    required double latitude,
    required double longitude,
  }) = _Coordinates;

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
}
