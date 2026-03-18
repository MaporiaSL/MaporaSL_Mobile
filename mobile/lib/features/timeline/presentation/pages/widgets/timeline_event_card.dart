import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import 'package:intl/intl.dart';

class TimelineEventCard extends StatelessWidget {
  final TimelineEvent event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCardGradient(),
        ),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor().withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getBorderColor().withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Placeholder for future gamified interaction
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildQuestBadge(context),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textMuted.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(event.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark.withOpacity(0.85),
                        height: 1.4,
                      ),
                ),
                if (_hasExtraContent()) ...[
                  const SizedBox(height: 16),
                  _buildExtraContent(context),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCardGradient() {
    switch (event.type) {
      case TimelineEventType.upcoming:
        return [
          const Color(0xFFE8F5E9),
          const Color(0xFFC8E6C9),
        ];
      case TimelineEventType.achievement:
        return [
          const Color(0xFFFFF7E6),
          const Color(0xFFFFEDB3),
        ];
      case TimelineEventType.photo:
        return [
          const Color(0xFFE6F9FA),
          const Color(0xFFC7F1F4),
        ];
      case TimelineEventType.visit:
      default:
        return [
          const Color(0xFFFFFFFF),
          const Color(0xFFF3F5F7),
        ];
    }
  }

  Color _getShadowColor() {
    switch (event.type) {
      case TimelineEventType.upcoming:
        return const Color(0xFF4CAF50);
      case TimelineEventType.achievement:
        return AppColors.accent;
      case TimelineEventType.photo:
        return AppColors.primary;
      case TimelineEventType.visit:
      default:
        return Colors.black26;
    }
  }

  Color _getBorderColor() {
    switch (event.type) {
      case TimelineEventType.upcoming:
        return const Color(0xFF81C784);
      case TimelineEventType.achievement:
        return AppColors.accent;
      case TimelineEventType.photo:
        return AppColors.primaryLight;
      case TimelineEventType.visit:
      default:
        return AppColors.border;
    }
  }

  Widget _buildQuestBadge(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (event.type) {
      case TimelineEventType.visit:
        label = 'VISIT';
        color = AppColors.primary;
        icon = Icons.location_on_rounded;
        break;
      case TimelineEventType.photo:
        label = 'MEMORY';
        color = AppColors.secondary;
        icon = Icons.camera_alt_rounded;
        break;
      case TimelineEventType.upcoming:
        label = 'PLANNED';
        color = const Color(0xFF4CAF50);
        icon = Icons.event_available_rounded;
        break;
      case TimelineEventType.achievement:
        label = 'ACHIEVEMENT';
        color = AppColors.accent;
        icon = Icons.stars_rounded;
        break;
      default:
        label = 'EVENT';
        color = AppColors.textMuted;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasExtraContent() {
    if (event.type == TimelineEventType.photo && event.metadata.containsKey('imageUrl')) {
      return true;
    }
    if (event.type == TimelineEventType.achievement && event.metadata.containsKey('districtId')) {
      return true;
    }
    return false;
  }

  Widget _buildExtraContent(BuildContext context) {
    if (event.type == TimelineEventType.photo) {
      final imageUrl = event.metadata['imageUrl'] as String;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              width: double.infinity,
              color: AppColors.surfaceMuted,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 40),
                  const SizedBox(height: 8),
                  Text('Image unavailable', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (event.type == TimelineEventType.achievement) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Badge Unlocked!',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amazing progress. Keep exploring!',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
