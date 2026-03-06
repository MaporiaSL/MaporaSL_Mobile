import 'package:flutter/material.dart';
import '../data/models/place_visit.dart';

/// Predefined achievements for place visits
class PlaceAchievements {
  static const List<AchievementDefinition> definitions = [
    // Category-based achievements
    AchievementDefinition(
      id: 'temple_explorer',
      title: 'Temple Explorer',
      description: 'Visit 10 temples',
      badgeEmoji: '🕉️',
      category: 'temples',
      threshold: 10,
      rewards: 100,
      color: Color(0xFFFFA500),
    ),
    AchievementDefinition(
      id: 'beach_bum',
      title: 'Beach Bum',
      description: 'Visit 10 beaches',
      badgeEmoji: '🏖️',
      category: 'beaches',
      threshold: 10,
      rewards: 100,
      color: Color(0xFF00CED1),
    ),
    AchievementDefinition(
      id: 'mountain_climber',
      title: 'Mountain Climber',
      description: 'Visit 10 mountains',
      badgeEmoji: '⛰️',
      category: 'mountains',
      threshold: 10,
      rewards: 100,
      color: Color(0xFF8B4513),
    ),
    AchievementDefinition(
      id: 'historic_hunter',
      title: 'Historic Hunter',
      description: 'Visit 10 historical sites',
      badgeEmoji: '🏛️',
      category: 'historical',
      threshold: 10,
      rewards: 100,
      color: Color(0xFFBFA76A),
    ),
    AchievementDefinition(
      id: 'wildlife_watcher',
      title: 'Wildlife Watcher',
      description: 'Visit 10 wildlife locations',
      badgeEmoji: '🦁',
      category: 'wildlife',
      threshold: 10,
      rewards: 100,
      color: Color(0xFF228B22),
    ),

    // District-based achievements
    AchievementDefinition(
      id: 'all_districts',
      title: 'All Districts Explorer',
      description: 'Visit places in all 25 districts',
      badgeEmoji: '🗺️',
      category: 'all_districts',
      threshold: 25,
      rewards: 500,
      color: Color(0xFF4169E1),
    ),

    // Visit count achievements
    AchievementDefinition(
      id: 'prolific_visitor_25',
      title: 'Prolific Visitor',
      description: 'Record 25 visits',
      badgeEmoji: '🎯',
      category: 'visit_count',
      threshold: 25,
      rewards: 150,
      color: Color(0xFFDC143C),
    ),
    AchievementDefinition(
      id: 'prolific_visitor_50',
      title: 'Legendary Traveler',
      description: 'Record 50 visits',
      badgeEmoji: '👑',
      category: 'visit_count',
      threshold: 50,
      rewards: 300,
      color: Color(0xFFFFD700),
    ),
    AchievementDefinition(
      id: 'prolific_visitor_100',
      title: 'Master of Exploration',
      description: 'Record 100 visits',
      badgeEmoji: '🌟',
      category: 'visit_count',
      threshold: 100,
      rewards: 500,
      color: Color(0xFFFF69B4),
    ),

    // Photo achievements
    AchievementDefinition(
      id: 'photo_collector_10',
      title: 'Photo Collector',
      description: 'Upload 10 photos with visits',
      badgeEmoji: '📷',
      category: 'photos',
      threshold: 10,
      rewards: 100,
      color: Color(0xFF4B0082),
    ),

    // Streak achievements
    AchievementDefinition(
      id: 'on_a_roll_7',
      title: 'On a Roll',
      description: 'Visit a place every day for 7 days',
      badgeEmoji: '🔥',
      category: 'streak',
      threshold: 7,
      rewards: 200,
      color: Color(0xFFFF4500),
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
  final int threshold;
  final int rewards;
  final Color color;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeEmoji,
    required this.category,
    required this.threshold,
    required this.rewards,
    required this.color,
  });
}

/// Achievement progress tracker
class AchievementProgress {
  final String id;
  final AchievementDefinition definition;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementProgress({
    required this.id,
    required this.definition,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// Progress as percentage (0.0-1.0)
  double get progressPercent =>
      (currentProgress / definition.threshold).clamp(0, 1).toDouble();

  /// Check if achievement is close to unlocking
  bool get isNearlyUnlocked => progressPercent >= 0.8 && !isUnlocked;

  /// Human-readable progress text
  String get progressText => '$currentProgress / ${definition.threshold}';
}

/// Widget to display achievement card
class AchievementCard extends StatelessWidget {
  final AchievementProgress achievement;
  final VoidCallback? onTap;
  final bool showProgress;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final def = achievement.definition;
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isUnlocked
            ? def.color.withOpacity(0.15)
            : Colors.grey.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isUnlocked ? 1 : 0.4,
                child: Text(
                  def.badgeEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              if (isUnlocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                def.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? def.color : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (showProgress)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: achievement.progressPercent,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(
                        isUnlocked ? def.color : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.progressText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display achievement unlock animation
class AchievementUnlockAlert extends StatefulWidget {
  final AchievementDefinition achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockAlert({
    super.key,
    required this.achievement,
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

    // Auto-dismiss
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: widget.achievement.color.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.achievement.badgeEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'ACHIEVEMENT UNLOCKED!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${widget.achievement.rewards} points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
