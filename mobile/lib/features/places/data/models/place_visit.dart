import 'package:json_annotation/json_annotation.dart';

part 'place_visit.g.dart';

/// Metadata collected at visit time for anti-cheat validation
@JsonSerializable()
class VisitMetadata {
  /// GPS coordinates (lat, lng, accuracy in meters)
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  /// Device orientation & compass heading
  final double? compassHeading; // 0-360 degrees
  final double? pitch; // device tilt
  final double? roll; // device rotation

  /// Device & environment info
  final String deviceModel;
  final String osVersion;
  final double? lightLevel; // ambient light sensor
  final int? cellSignalStrength; // cellular signal

  /// Photo metadata (if provided)
  final String? photoExifLat;
  final String? photoExifLon;
  final String? photoExifTimestamp;
  final String? photoExifDatestamp;

  /// Behavioral data
  final int collectionTimeMs; // time to collect all data
  final bool isLocationSpoofed; // device reported
  final String? sensorProvider; // 'gps', 'network', 'fused'

  VisitMetadata({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.compassHeading,
    this.pitch,
    this.roll,
    required this.deviceModel,
    required this.osVersion,
    this.lightLevel,
    this.cellSignalStrength,
    this.photoExifLat,
    this.photoExifLon,
    this.photoExifTimestamp,
    this.photoExifDatestamp,
    required this.collectionTimeMs,
    required this.isLocationSpoofed,
    this.sensorProvider,
  });

  factory VisitMetadata.fromJson(Map<String, dynamic> json) =>
      _$VisitMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$VisitMetadataToJson(this);
}

/// Request sent to server to record a place visit
@JsonSerializable()
class PlaceVisitRequest {
  /// Place being visited
  final String placeId;

  /// Optional user notes
  final String? notes;

  /// Optional photo URL (already uploaded to storage)
  final String? photoUrl;

  /// Detailed metadata for anti-cheat validation
  final VisitMetadata metadata;

  /// Request signature for replay attack prevention
  final String requestSignature;

  /// Timestamp when request was created (client-side, for reference)
  final DateTime createdAt;

  PlaceVisitRequest({
    required this.placeId,
    this.notes,
    this.photoUrl,
    required this.metadata,
    required this.requestSignature,
    required this.createdAt,
  });

  factory PlaceVisitRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceVisitRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceVisitRequestToJson(this);
}

/// Place visit record returned from server
@JsonSerializable()
class PlaceVisit {
  /// Unique visit ID
  final String id;

  /// References
  final String placeId;
  final String userId;

  /// Visit details
  final String? notes;
  final String? photoUrl;

  /// Server-verified timestamp (authoritative)
  final DateTime visitedAt;

  /// Server anti-cheat validation result
  final PlaceVisitValidation validation;

  /// Achievement unlocked (if any)
  final String? achievementId;
  final String? achievementTitle;

  /// For linking to trips (optional, separate from visit)
  final String? tripId;

  /// Visit statistics
  final int likesCount;
  final bool isLikedByCurrentUser;

  /// User coordinates at time of visit (for error display)
  final UserCoordinates? userCoordinates;

  PlaceVisit({
    required this.id,
    required this.placeId,
    required this.userId,
    this.notes,
    this.photoUrl,
    required this.visitedAt,
    required this.validation,
    this.achievementId,
    this.achievementTitle,
    this.tripId,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
    this.userCoordinates,
  });

  factory PlaceVisit.fromJson(Map<String, dynamic> json) =>
      _$PlaceVisitFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceVisitToJson(this);
}

/// User coordinates at time of visit
@JsonSerializable()
class UserCoordinates {
  final double latitude;
  final double longitude;

  UserCoordinates({required this.latitude, required this.longitude});

  factory UserCoordinates.fromJson(Map<String, dynamic> json) =>
      _$UserCoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$UserCoordinatesToJson(this);
}

/// Anti-cheat validation result from server
@JsonSerializable()
class PlaceVisitValidation {
  /// Overall validation status
  final bool isValid;
  final String status; // 'approved', 'suspicious', 'rejected'
  final double confidence; // 0.0-1.0 confidence score

  /// Individual check results
  final bool gpsAccuracyValid; // < 30m accuracy
  final bool geoFencingValid; // within 200m of place
  final bool headingValid; // facing correct direction
  final bool photoExifValid; // photo EXIF matches coordinates
  final bool deviceSignatureSuspicious; // likely spoof app
  final bool beingThrottled; // violated rate limit
  final bool speedValid; // distance/time ratio reasonable

  /// Detailed reason if invalid
  final String? invalidReason;

  /// Metadata flags
  final String? flaggedReason; // 'low_accuracy', 'photo_mismatch', etc.
  final int flagSeverity; // 1-5 (5 = critical)

  PlaceVisitValidation({
    required this.isValid,
    required this.status,
    required this.confidence,
    required this.gpsAccuracyValid,
    required this.geoFencingValid,
    required this.headingValid,
    required this.photoExifValid,
    required this.deviceSignatureSuspicious,
    required this.beingThrottled,
    required this.speedValid,
    this.invalidReason,
    this.flaggedReason,
    this.flagSeverity = 1,
  });

  factory PlaceVisitValidation.fromJson(Map<String, dynamic> json) =>
      _$PlaceVisitValidationFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceVisitValidationToJson(this);
}

/// User achievement for visiting places
@JsonSerializable()
class PlaceAchievement {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String badgeEmoji;
  final String
  category; // 'temples', 'beaches', 'mountains', 'all_districts', etc.
  final int threshold; // e.g., "visit 10 temples"
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int rewards; // points/coins earned

  PlaceAchievement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.badgeEmoji,
    required this.category,
    required this.threshold,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    this.rewards = 0,
  });

  factory PlaceAchievement.fromJson(Map<String, dynamic> json) =>
      _$PlaceAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceAchievementToJson(this);

  /// Progress as percentage (0.0-1.0)
  double get progressPercent =>
      (currentProgress / threshold).clamp(0, 1).toDouble();
}

/// User visit statistics
@JsonSerializable()
class UserVisitStats {
  final String userId;
  final int totalVisits;
  final int uniquePlacesVisited;
  final int uniqueDistrictsVisited;
  final Map<String, int> visitsByCategory; // 'temples': 5, 'beaches': 3
  final Map<String, int> visitsByDistrict; // 'Colombo': 8, 'Galle': 3
  final int achievementsUnlocked;
  final int totalRewards;
  final DateTime lastVisitAt;
  final String currentStreak; // e.g., '7 days'

  UserVisitStats({
    required this.userId,
    required this.totalVisits,
    required this.uniquePlacesVisited,
    required this.uniqueDistrictsVisited,
    required this.visitsByCategory,
    required this.visitsByDistrict,
    required this.achievementsUnlocked,
    required this.totalRewards,
    required this.lastVisitAt,
    required this.currentStreak,
  });

  factory UserVisitStats.fromJson(Map<String, dynamic> json) =>
      _$UserVisitStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserVisitStatsToJson(this);
}
