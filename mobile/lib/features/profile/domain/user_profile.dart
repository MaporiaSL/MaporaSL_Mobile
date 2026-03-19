class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final String hometownDistrict;
  final String preferredLanguage;
  final List<String> travelInterests;
  final int totalSubmitted;
  final int approvedCount;
  final double approvalRate;
  final List<ContributionBadge> badges;
  final List<ContributedPlace> contributedPlaces;
  final int leaderboardRank;
  final int impactCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.hometownDistrict,
    required this.preferredLanguage,
    required this.travelInterests,
    required this.totalSubmitted,
    required this.approvedCount,
    required this.approvalRate,
    required this.badges,
    required this.contributedPlaces,
    required this.leaderboardRank,
    required this.impactCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user']['id'] ?? '',
      name: json['user']['name'] ?? '',
      email: json['user']['email'] ?? '',
      avatarUrl: json['user']['avatarUrl'] ?? '',
        bio: json['user']['bio'] ?? '',
        hometownDistrict: json['user']['hometownDistrict'] ?? '',
        preferredLanguage: json['user']['preferredLanguage'] ?? '',
        travelInterests: (json['user']['travelInterests'] as List?)
            ?.whereType<String>()
            .toList() ??
          const [],
      totalSubmitted: json['stats']['totalSubmitted'] ?? 0,
      approvedCount: json['stats']['approvedCount'] ?? 0,
      approvalRate: (json['stats']['approvalRate'] ?? 0).toDouble(),
      badges: (json['badges'] as List?)
          ?.map((b) => ContributionBadge.fromJson(b))
          .toList() ?? [],
      contributedPlaces: const [],
      leaderboardRank: json['leaderboardRank'] ?? 0,
      impactCount: json['impactCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'hometownDistrict': hometownDistrict,
      'preferredLanguage': preferredLanguage,
      'travelInterests': travelInterests,
    },
    'stats': {
      'totalSubmitted': totalSubmitted,
      'approvedCount': approvedCount,
      'approvalRate': approvalRate,
    },
    'badges': badges.map((b) => b.toJson()).toList(),
    'leaderboardRank': leaderboardRank,
    'impactCount': impactCount,
  };
}

class ContributionBadge {
  final String name;
  final String icon;
  final DateTime? earnedAt;
  final int contributionCount;

  ContributionBadge({
    required this.name,
    required this.icon,
    this.earnedAt,
    required this.contributionCount,
  });

  factory ContributionBadge.fromJson(Map<String, dynamic> json) {
    return ContributionBadge(
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🏅',
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : null,
      contributionCount: json['contributionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'earnedAt': earnedAt?.toIso8601String(),
    'contributionCount': contributionCount,
  };
}

class ContributedPlace {
  final String id;
  final String name;
  final String description;
  final bool approved;
  final String status;
  final String category;
  final String province;
  final String district;
  final double? latitude;
  final double? longitude;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String photoUrl;
  final List<String> photoUrls;
  final String? promotedPlaceId;
  final String? userId;
  final List<ContributionBadge> approvalBadgePreview;
  final int? currentApprovedCount;

  ContributedPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.approved,
    required this.status,
    required this.category,
    required this.province,
    required this.district,
    this.latitude,
    this.longitude,
    this.submittedAt,
    this.reviewedAt,
    this.approvedAt,
    this.rejectionReason,
    required this.photoUrl,
    required this.photoUrls,
    this.promotedPlaceId,
    this.userId,
    this.approvalBadgePreview = const [],
    this.currentApprovedCount,
  });

  factory ContributedPlace.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    final status = rawStatus.isEmpty ? (json['approved'] == true ? 'approved' : 'pending') : rawStatus;
    return ContributedPlace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      approved: status == 'approved' || json['approved'] == true,
      status: status,
        category: json['category']?.toString() ?? 'other',
        province: json['province']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? '',
        photoUrls: (json['photoUrls'] as List?)
            ?.whereType<String>()
            .toList() ??
          ((json['photoUrl']?.toString().isNotEmpty ?? false)
            ? [json['photoUrl'].toString()]
            : const []),
        promotedPlaceId: json['promotedPlaceId']?.toString(),
        userId: json['userId']?.toString(),
        approvalBadgePreview: (json['approvalBadgePreview'] as List?)
            ?.whereType<Map>()
            .map((e) => ContributionBadge.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
          const [],
        currentApprovedCount: json['currentApprovedCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'approved': approved,
    'status': status,
    'category': category,
    'province': province,
    'district': district,
    'latitude': latitude,
    'longitude': longitude,
    'submittedAt': submittedAt?.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'approvedAt': approvedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'photoUrl': photoUrl,
    'photoUrls': photoUrls,
    'promotedPlaceId': promotedPlaceId,
    'userId': userId,
    'approvalBadgePreview': approvalBadgePreview.map((b) => b.toJson()).toList(),
    'currentApprovedCount': currentApprovedCount,
  };
}
