import 'trip_model.dart';

/// DTO for creating a new trip
class CreateTripDto {
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripLocation>? locations;
  final String? tripType;
  final String? startingPoint;
  final String? status;

  const CreateTripDto({
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.locations,
    this.tripType,
    this.startingPoint,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (locations != null && locations!.isNotEmpty) 
        'locations': locations!.map((l) => l.name).toList(),
      if (tripType != null) 'tripType': tripType,
      if (startingPoint != null) 'startingPoint': startingPoint,
      if (status != null) 'status': status,
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
  final String? status;

  const UpdateTripDto({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.locations,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (endDate != null) map['endDate'] = endDate!.toIso8601String();
    if (locations != null) 
      map['locations'] = locations!.map((l) => l.name).toList();
    if (status != null) map['status'] = status;
    return map;
  }

  bool get isEmpty => toJson().isEmpty;
}
