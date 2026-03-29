import 'package:flutter/material.dart';

/// Predefined achievements for place visits
class PlaceAchievements {
  static const List<AchievementDefinition> definitions = [
    // Pioneer Track (Overall exploration)
    AchievementDefinition(
      id: 'prolific_visitor',
      title: 'Prolific Visitor',
      description: 'Record visits to hidden gems',
      badgeEmoji: '🎯',
      category: 'visit_count',
      track: 'Pioneer',
      tiers: [5, 25, 50, 100],
      tierRewards: [50, 150, 300, 500],
    ),
    AchievementDefinition(
      id: 'village_explorer',
      title: 'Village Explorer',
      description: 'Discover the heart of rural Sri Lanka',
      badgeEmoji: '🏘️',
      category: 'villages',
      track: 'Pioneer',
      tiers: [2, 5, 12, 25],
      tierRewards: [50, 150, 300, 600],
    ),

    // Naturalist Track (Nature & Adventure)
    AchievementDefinition(
      id: 'mountain_climber',
      title: 'Mountain Climber',
      description: 'Conquer the peaks and misty hills',
      badgeEmoji: '⛰️',
      category: 'mountains',
      track: 'Naturalist',
      tiers: [2, 5, 15, 30],
      tierRewards: [100, 200, 500, 1000],
    ),
    AchievementDefinition(
      id: 'beach_master',
      title: 'Beach Master',
      description: 'Visit tropical coastal gems',
      badgeEmoji: '🏖️',
      category: 'beaches',
      track: 'Naturalist',
      tiers: [3, 10, 25, 50],
      tierRewards: [50, 150, 400, 800],
    ),
    AchievementDefinition(
      id: 'wildlife_watcher',
      title: 'Wildlife Watcher',
      description: 'Visit national parks and wildlife spots',
      badgeEmoji: '🐆',
      category: 'wildlife',
      track: 'Naturalist',
      tiers: [2, 10, 25, 50],
      tierRewards: [50, 150, 400, 800],
    ),

    // Devotee Track (Culture & History)
    AchievementDefinition(
      id: 'temple_curator',
      title: 'Temple Curator',
      description: 'Visit sacred temples and shrines',
      badgeEmoji: '🛕',
      category: 'temples',
      track: 'Devotee',
      tiers: [3, 10, 25, 50],
      tierRewards: [50, 150, 400, 800],
    ),
    AchievementDefinition(
      id: 'historic_hunter',
      title: 'Historic Hunter',
      description: 'Visit ancient ruins and heritage sites',
      badgeEmoji: '🏛️',
      category: 'historical',
      track: 'Devotee',
      tiers: [3, 10, 25, 50],
      tierRewards: [50, 150, 400, 800],
    ),

    // Chronicler Track (Contributions)
    AchievementDefinition(
      id: 'photo_collector',
      title: 'Photo Collector',
      description: 'Visualize your journey with photos',
      badgeEmoji: '📸',
      category: 'photos',
      track: 'Chronicler',
      tiers: [5, 25, 100, 250],
      tierRewards: [50, 150, 500, 1200],
    ),
    AchievementDefinition(
      id: 'grand_reviewer',
      title: 'Grand Reviewer',
      description: 'Guide others with your insights',
      badgeEmoji: '✍️',
      category: 'reviews',
      track: 'Chronicler',
      tiers: [3, 10, 25, 50],
      tierRewards: [50, 120, 300, 600],
    ),

    // Social Track (Identity & Connection)
    AchievementDefinition(
      id: 'social_butterfly',
      title: 'Social Butterfly',
      description: 'Connect and share your discoveries',
      badgeEmoji: '🦋',
      category: 'social',
      track: 'Social',
      tiers: [5, 15, 30, 60],
      tierRewards: [40, 100, 250, 500],
    ),
  ];

  /// Get achievement by ID
  static AchievementDefinition? getById(String id) {
    try {
      return definitions.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all achievements for a category
  static List<AchievementDefinition> getByCategory(String category) {
    return definitions.where((a) => a.category == category).toList();
  }
}

/// Achievement definition with metadata
class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String badgeEmoji;
  final String category;
  final String track;
  final List<int> tiers;
  final List<int> tierRewards;

  static List<AchievementDefinition> get all => PlaceAchievements.definitions;

  static const List<Color> tierColors = [
    Color(0xFFCD7F32), // Bronze
    Color(0xFFC0C0C0), // Silver
    Color(0xFFFFD700), // Gold
    Color(0xFFE5E4E2), // Platinum
  ];

  static const List<String> tierNames = [
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
  ];

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeEmoji,
    required this.category,
    required this.track,
    required this.tiers,
    required this.tierRewards,
  });

  int getThreshold(int tierIndex) => tiers[tierIndex.clamp(0, tiers.length - 1)];
  int getReward(int tierIndex) => tierRewards[tierIndex.clamp(0, tierRewards.length - 1)];
}

/// Achievement progress tracker
class AchievementProgress {
  final String id;
  final AchievementDefinition definition;
  final int currentProgress;
  final int currentTier; // -1 = Locked, 0 = Bronze, 1 = Silver, 2 = Gold, 3 = Platinum
  final DateTime? unlockedAt;

  AchievementProgress({
    required this.id,
    required this.definition,
    required this.currentProgress,
    required this.currentTier,
    this.unlockedAt,
  });

  /// Factory to create progress from current count
  factory AchievementProgress.fromProgress(AchievementDefinition definition, int currentProgress) {
    int currentTier = -1;
    for (int i = 0; i < definition.tiers.length; i++) {
      if (currentProgress >= definition.tiers[i]) {
        currentTier = i;
      } else {
        break;
      }
    }
    return AchievementProgress(
      id: definition.id,
      definition: definition,
      currentProgress: currentProgress,
      currentTier: currentTier,
    );
  }

  bool get isUnlocked => currentTier >= 0;

  /// Total points earned across all completed tiers
  int get totalEarnedPoints {
    if (currentTier == -1) return 0;
    int total = 0;
    for (int i = 0; i <= currentTier; i++) {
      total += definition.tierRewards[i];
    }
    return total;
  }

  double get progressPercent {
    if (currentTier >= definition.tiers.length - 1) return 1.0;
    final nextThreshold = definition.getThreshold(currentTier + 1);
    final prevThreshold = currentTier == -1 ? 0 : definition.getThreshold(currentTier);
    return ((currentProgress - prevThreshold) / (nextThreshold - prevThreshold)).clamp(0, 1).toDouble();
  }

  String get tierName => currentTier == -1 ? 'Locked' : AchievementDefinition.tierNames[currentTier];
  Color get tierColor => currentTier == -1 ? Colors.grey : AchievementDefinition.tierColors[currentTier];
  
  String get progressText {
    if (currentTier >= definition.tiers.length - 1) return 'MAXED';
    return '$currentProgress / ${definition.getThreshold(currentTier + 1)}';
  }
}

/// Widget to display achievement card
class AchievementCard extends StatelessWidget {
  final AchievementProgress achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final def = achievement.definition;
    final isUnlocked = achievement.isUnlocked;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tierColor = achievement.tierColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? tierColor.withOpacity(0.08) : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? tierColor.withOpacity(0.3) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked ? [BoxShadow(color: tierColor.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.2,
                  child: Text(def.badgeEmoji, style: const TextStyle(fontSize: 32)),
                ),
                if (isUnlocked)
                  Positioned(
                    bottom: -2, right: -2,
                    child: Icon(Icons.verified, color: tierColor, size: 14),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              def.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
                color: isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.tierName.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 8,
                color: tierColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progressPercent,
                minHeight: 4,
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(tierColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.progressText,
              style: TextStyle(fontSize: 8, color: isDark ? Colors.white24 : Colors.black26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display achievement unlock animation
class AchievementUnlockAlert extends StatefulWidget {
  final AchievementDefinition achievement;
  final int tierIndex;
  final VoidCallback? onDismiss;

  const AchievementUnlockAlert({
    super.key,
    required this.achievement,
    required this.tierIndex,
    this.onDismiss,
  });

  @override
  State<AchievementUnlockAlert> createState() => _AchievementUnlockAlertState();
}

class _AchievementUnlockAlertState extends State<AchievementUnlockAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementDefinition.tierColors[widget.tierIndex];
    final tierName = AchievementDefinition.tierNames[widget.tierIndex];
    final reward = widget.achievement.getReward(widget.tierIndex);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tierColor.withOpacity(0.9), tierColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: tierColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.achievement.badgeEmoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                '$tierName Achievement!'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.achievement.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.achievement.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '+$reward TROPHY POINTS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

