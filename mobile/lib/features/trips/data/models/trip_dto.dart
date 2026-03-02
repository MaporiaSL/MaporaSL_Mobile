import 'trip_model.dart';

/// DTO for creating a new trip
class CreateTripDto {
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripLocation>? locations;

  const CreateTripDto({
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.locations,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (locations != null && locations!.isNotEmpty) 'locations': locations,
    };
  }
}

/// DTO for updating an existing trip
class UpdateTripDto {
  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TripLocation>? locations;

  const UpdateTripDto({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.locations,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (endDate != null) map['endDate'] = endDate!.toIso8601String();
    if (locations != null) map['locations'] = locations;
    return map;
  }

  bool get isEmpty => toJson().isEmpty;
}
