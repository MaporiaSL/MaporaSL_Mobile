import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

enum TripStatus { upcoming, active, completed }

/// Trip model representing a user's travel adventure
@JsonSerializable()
class TripModel {
  final String id;
  final String userId;
  final String title; // Changed from 'name' to match backend 'title' field
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripLocation>? locations;
  final String? status; // 'scheduled', 'planned', 'completed', etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optional metadata for planning/clone flows
  final String? startingPoint;
  final String? tripType;
  final String? budgetLevel;
  final double? estimatedCost;

  /// Indicates if trip was cloned from a template
  @JsonKey(defaultValue: false)
  final bool isCloned;

  /// Template reference if cloned
  final String? originalTemplateId;

  /// Cached completion percentage from backend (0-100)
  @JsonKey(defaultValue: 0)
  final int completionPercentageCached;

  // These will be populated from separate destination queries or aggregated by backend
  @JsonKey(defaultValue: 0)
  final int destinationCount;

  @JsonKey(defaultValue: 0)
  final int visitedCount;

  const TripModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.locations,
    this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startingPoint,
    this.tripType,
    this.budgetLevel,
    this.estimatedCost,
    this.isCloned = false,
    this.originalTemplateId,
    this.completionPercentageCached = 0,
    this.destinationCount = 0,
    this.visitedCount = 0,
  });

  /// Completion rate as percentage (0.0 to 1.0)
  double get completionRate =>
      destinationCount > 0 ? visitedCount / destinationCount : 0.0;

  /// Completion percentage as integer (0-100)
  int get completionPercentage => completionPercentageCached > 0
      ? completionPercentageCached
      : (completionRate * 100).round();

  /// Trip status based on current date
  TripStatus get timelineStatus {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return TripStatus.upcoming;
    if (now.isAfter(endDate)) return TripStatus.completed;
    return TripStatus.active;
  }

  /// Status display text for gamified UI
  String get statusLabel {
    switch (timelineStatus) {
      case TripStatus.upcoming:
        return 'Planned';
      case TripStatus.active:
        return 'Active Quest';
      case TripStatus.completed:
        return 'Completed';
    }
  }

  /// Emoji for trip status
  String get statusEmoji {
    switch (timelineStatus) {
      case TripStatus.upcoming:
        return '📅';
      case TripStatus.active:
        return '⚡';
      case TripStatus.completed:
        return '✅';
    }
  }

  /// Duration in days
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// Format date range for display
  String get dateRangeFormatted {
    final formatter = _DateFormatter();
    return formatter.formatRange(startDate, endDate);
  }

  /// Objectives/cleared text for gamified UI
  String get objectivesText =>
      '$destinationCount Objectives • $visitedCount Cleared';

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  TripModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<TripLocation>? locations,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? destinationCount,
    int? visitedCount,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      destinationCount: destinationCount ?? this.destinationCount,
      visitedCount: visitedCount ?? this.visitedCount,
    );
  }
}

/// Helper class for date formatting
class _DateFormatter {
  String formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Same month: "Dec 1 - 15, 2025"
      return '${_monthName(start.month)} ${start.day} - ${end.day}, ${start.year}';
    } else if (start.year == end.year) {
      // Same year: "Dec 1 - Jan 15, 2025"
      return '${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}, ${start.year}';
    } else {
      // Different years: "Dec 1, 2024 - Jan 15, 2025"
      return '${_monthName(start.month)} ${start.day}, ${start.year} - ${_monthName(end.month)} ${end.day}, ${end.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Represents a specific location in a trip
@JsonSerializable()
class TripLocation {
  final String name;
  final int day;

  const TripLocation({required this.name, required this.day});

  factory TripLocation.fromJson(Map<String, dynamic> json) =>
      _$TripLocationFromJson(json);

  Map<String, dynamic> toJson() => _$TripLocationToJson(this);
}
