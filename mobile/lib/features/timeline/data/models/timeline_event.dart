enum TimelineEventType {
  visit,
  photo,
  achievement,
  upcoming,
  completedTrip,
  unknown
}

class TimelineEvent {
  final String id;
  final TimelineEventType type;
  final DateTime timestamp;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;

  // Completed-trip specific fields (non-null only for completedTrip type)
  final int completionPercentage;
  final int destinationCount;
  final int visitedCount;
  final String? tripId;

  TimelineEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.metadata,
    this.completionPercentage = 0,
    this.destinationCount = 0,
    this.visitedCount = 0,
    this.tripId,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    TimelineEventType eventType;
    switch (json['type']) {
      case 'VISIT':
        eventType = TimelineEventType.visit;
        break;
      case 'UPCOMING':
        eventType = TimelineEventType.upcoming;
        break;
      case 'PHOTO':
        eventType = TimelineEventType.photo;
        break;
      case 'ACHIEVEMENT':
        eventType = TimelineEventType.achievement;
        break;
      case 'COMPLETED_TRIP':
        eventType = TimelineEventType.completedTrip;
        break;
      default:
        eventType = TimelineEventType.unknown;
    }

    return TimelineEvent(
      id: json['id'] as String,
      type: eventType,
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      destinationCount: json['destinationCount'] as int? ?? 0,
      visitedCount: json['visitedCount'] as int? ?? 0,
      tripId: json['tripId'] as String?,
    );
  }
}
