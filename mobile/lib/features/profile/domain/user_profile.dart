class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
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
  final DateTime? approvedAt;

  ContributedPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.approved,
    this.approvedAt,
  });

  factory ContributedPlace.fromJson(Map<String, dynamic> json) {
    return ContributedPlace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      approved: json['approved'] ?? false,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'approved': approved,
    'approvedAt': approvedAt?.toIso8601String(),
  };
}
