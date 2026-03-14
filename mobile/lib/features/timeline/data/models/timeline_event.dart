enum TimelineEventType {
  visit,
  photo,
  achievement,
  unknown
}

class TimelineEvent {
  final String id;
  final TimelineEventType type;
  final DateTime timestamp;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;

  TimelineEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.metadata,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    TimelineEventType eventType;
    switch (json['type']) {
      case 'VISIT':
        eventType = TimelineEventType.visit;
        break;
      case 'PHOTO':
        eventType = TimelineEventType.photo;
        break;
      case 'ACHIEVEMENT':
        eventType = TimelineEventType.achievement;
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
    );
  }
}
