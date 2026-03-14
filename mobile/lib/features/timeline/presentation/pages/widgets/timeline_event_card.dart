import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../models/timeline_event.dart';
import 'package:intl/intl.dart';

class TimelineEventCard extends StatelessWidget {
  final TimelineEvent event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight.withOpacity(0.8),
                  ),
            ),
            if (_hasExtraContent()) ...[
              const SizedBox(height: 12),
              _buildExtraContent(context),
            ]
          ],
        ),
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      );
    }

    if (event.type == TimelineEventType.achievement) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: AppColors.accent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Explorer Badge Unlocked!',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
