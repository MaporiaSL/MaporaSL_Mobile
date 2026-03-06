class VisitModel {
  final String id;
  final String userId;
  final String placeId;
  final double latitude;
  final double longitude;
  final DateTime visitedAt;
  final bool isVerified;
  final String? rejectionReason;

  VisitModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.visitedAt,
    required this.isVerified,
    this.rejectionReason,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      placeId: json['placeId'] ?? '',
      latitude: (json['coordinates']?['latitude'] ?? 0).toDouble(),
      longitude: (json['coordinates']?['longitude'] ?? 0).toDouble(),
      visitedAt: DateTime.parse(json['visitedAt'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'visitedAt': visitedAt.toIso8601String(),
    };
  }
}
