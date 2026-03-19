import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/models/place_visit.dart';

/// Badge widget showing visit status (visited/not visited)
class VisitStatusBadge extends StatelessWidget {
  final bool isVisited;
  final DateTime? visitedAt;
  final String size; // 'small', 'medium', 'large'

  const VisitStatusBadge({
    super.key,
    required this.isVisited,
    this.visitedAt,
    this.size = 'medium',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisited) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: _getIconSize(),
          ),
          if (visitedAt != null && size != 'small') ...[
            const SizedBox(height: 4),
            Text(_formatDate(visitedAt!), style: _getTextStyle(context)),
          ],
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case 'small':
        return const EdgeInsets.all(4);
      case 'medium':
        return const EdgeInsets.all(8);
      case 'large':
        return const EdgeInsets.all(12);
      default:
        return const EdgeInsets.all(8);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case 'small':
        return 4;
      case 'medium':
        return 8;
      case 'large':
        return 12;
      default:
        return 8;
    }
  }

  double _getIconSize() {
    switch (size) {
      case 'small':
        return 16;
      case 'medium':
        return 24;
      case 'large':
        return 32;
      default:
        return 24;
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    switch (size) {
      case 'small':
        return Theme.of(context).textTheme.labelSmall;
      case 'medium':
        return Theme.of(context).textTheme.labelSmall;
      case 'large':
        return Theme.of(context).textTheme.bodySmall;
      default:
        return Theme.of(context).textTheme.labelSmall;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}

/// Animated visit achievement popup
class VisitAchievementPopup extends StatefulWidget {
  final PlaceAchievement achievement;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const VisitAchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 5),
  });

  @override
  State<VisitAchievementPopup> createState() => _VisitAchievementPopupState();
}

class _VisitAchievementPopupState extends State<VisitAchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            _controller.reverse().then((_) {
              widget.onDismiss?.call();
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  widget.achievement.badgeEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ACHIEVEMENT UNLOCKED!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.achievement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.achievement.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini card showing visit history
class MiniVisitCard extends StatelessWidget {
  final PlaceVisit visit;
  final String placeName;
  final VoidCallback? onTap;

  const MiniVisitCard({
    super.key,
    required this.visit,
    required this.placeName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(visit.visitedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (visit.validation.status == 'approved')
              const Icon(Icons.verified, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

