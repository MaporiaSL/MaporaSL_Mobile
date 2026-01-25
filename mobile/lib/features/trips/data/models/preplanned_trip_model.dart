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
  final List<String> placeIds; // references to Place documents
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
    // Normalize places -> placeIds
    if (map['places'] is List) {
      map['placeIds'] = (map['places'] as List)
          .map(
            (e) => e is Map<String, dynamic>
                ? (e['_id'] ?? e['id'] ?? e).toString()
                : e.toString(),
          )
          .toList();
    }
    return _$PrePlannedTripModelFromJson(map);
  }

  Map<String, dynamic> toJson() => _$PrePlannedTripModelToJson(this);
}
