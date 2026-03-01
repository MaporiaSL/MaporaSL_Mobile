import 'package:json_annotation/json_annotation.dart';

part 'preplanned_trip_model.g.dart';

/// Template model for system-curated trips
@JsonSerializable()
class PrePlannedTripModel {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final int xpReward;
  final String difficulty; // Easy, Moderate, Hard
  final List<String> placeIds;
  final String? district;
  final Map<String, dynamic>? itinerary;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;

  const PrePlannedTripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.xpReward,
    required this.difficulty,
    required this.placeIds,
    this.district,
    this.itinerary,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
  });

  factory PrePlannedTripModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    // Normalize Mongo _id
    if (map.containsKey('_id')) {
      map['id'] = map['_id'].toString();
    }
    // Normalize itinerary if it's not a map
    if (map['itinerary'] != null && map['itinerary'] is! Map) {
      map['itinerary'] = <String, dynamic>{};
    }
    return _$PrePlannedTripModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$PrePlannedTripModelToJson(this);
}
