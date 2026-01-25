import 'package:json_annotation/json_annotation.dart';

part 'trip_stats_model.g.dart';

/// Explorer stats model for gamified stats display
@JsonSerializable()
class TripStatsModel {
  /// Total number of trips logged
  final int totalTrips;

  /// Total number of destinations/places across all trips
  final int totalDestinations;

  /// Total number of visited destinations
  final int totalVisited;

  /// Overall completion rate (0.0 to 1.0)
  final double completionRate;

  const TripStatsModel({
    required this.totalTrips,
    required this.totalDestinations,
    required this.totalVisited,
    required this.completionRate,
  });

  /// Traveler level based on total visited places
  /// Level 1: 0-9 visits
  /// Level 2: 10-24 visits
  /// Level 3: 25-49 visits
  /// Level 4: 50-99 visits
  /// Level 5: 100+ visits
  int get travelerLevel {
    if (totalVisited >= 100) return 5;
    if (totalVisited >= 50) return 4;
    if (totalVisited >= 25) return 3;
    if (totalVisited >= 10) return 2;
    return 1;
  }

  /// Level title for display
  String get levelTitle {
    switch (travelerLevel) {
      case 1:
        return 'Novice Explorer';
      case 2:
        return 'Adventurer';
      case 3:
        return 'Seasoned Traveler';
      case 4:
        return 'Expert Navigator';
      case 5:
        return 'Master Explorer';
      default:
        return 'Explorer';
    }
  }

  /// Completion percentage as integer (0-100)
  int get completionPercentage => (completionRate * 100).round();

  /// Empty stats for initial state
  factory TripStatsModel.empty() {
    return const TripStatsModel(
      totalTrips: 0,
      totalDestinations: 0,
      totalVisited: 0,
      completionRate: 0.0,
    );
  }

  factory TripStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TripStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripStatsModelToJson(this);
}
