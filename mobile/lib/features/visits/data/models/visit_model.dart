class VisitModel {
  final String id;
  final String userId;
  final String placeId;
  final double latitude;
  final double longitude;
  final DateTime visitedAt;
  final bool isVerified;
  final String? rejectionReason;
  final String? notes;
  final String? photoUrl;

  VisitModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.visitedAt,
    required this.isVerified,
    this.rejectionReason,
    this.notes,
    this.photoUrl,
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
      rejectionReason: json['reasons']?['rejectionReason'] ?? json['rejectionReason'],
      notes: json['notes'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'notes': notes,
      'photoUrl': photoUrl,
      'visitedAt': visitedAt.toIso8601String(),
    };
  }
}
