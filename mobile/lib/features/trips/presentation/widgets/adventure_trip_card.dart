import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';

/// Adventure trip card widget with gamified design
class AdventureTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AdventureTripCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = trip.status == TripStatus.active;

    return Card(
      elevation: isActive ? 6 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? const BorderSide(color: Colors.amber, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and status
              Row(
                children: [
                  // Trip emoji/icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTripEmoji(trip),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      trip.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status chip
                  _StatusChip(status: trip.status),
                ],
              ),
              const SizedBox(height: 12),

              // Date range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    trip.dateRangeFormatted,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    '${trip.durationDays} days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Objectives text (gamified)
              Text(
                trip.objectivesText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // Segmented progress bar (gamified style)
              _SegmentedProgressBar(
                progress: trip.completionRate,
                totalSegments: 10,
                color: _getProgressColor(trip.completionRate),
              ),
              const SizedBox(height: 8),

              // Progress percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exploration Progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    '${trip.completionPercentage}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(trip.completionRate),
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

  String _getTripEmoji(TripModel trip) {
    // Use location-based emojis if available, otherwise use status emoji
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      final firstLocation = trip.locations!.first.toLowerCase();
      if (firstLocation.contains('beach') || firstLocation.contains('sea')) {
        return '🏖️';
      }
      if (firstLocation.contains('mountain') ||
          firstLocation.contains('hill')) {
        return '🏔️';
      }
      if (firstLocation.contains('city')) return '🏙️';
      if (firstLocation.contains('temple')) return '⛩️';
    }
    return '✈️';
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.upcoming:
        return Colors.blue;
      case TripStatus.active:
        return Colors.amber;
      case TripStatus.completed:
        return Colors.green;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.50) return Colors.amber;
    if (progress >= 0.25) return Colors.orange;
    return Colors.blue;
  }
}

/// Status chip widget
class _StatusChip extends StatelessWidget {
  final TripStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getEmoji(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case TripStatus.upcoming:
        return Colors.blue;
      case TripStatus.active:
        return Colors.amber.shade700;
      case TripStatus.completed:
        return Colors.green;
    }
  }

  String _getLabel() {
    switch (status) {
      case TripStatus.upcoming:
        return 'Planned';
      case TripStatus.active:
        return 'Active Quest';
      case TripStatus.completed:
        return 'Completed';
    }
  }

  String _getEmoji() {
    switch (status) {
      case TripStatus.upcoming:
        return '📅';
      case TripStatus.active:
        return '⚡';
      case TripStatus.completed:
        return '✅';
    }
  }
}

/// Segmented progress bar with gamified appearance
class _SegmentedProgressBar extends StatelessWidget {
  final double progress;
  final int totalSegments;
  final Color color;

  const _SegmentedProgressBar({
    required this.progress,
    this.totalSegments = 10,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final filledSegments = (progress * totalSegments).round();

    return Row(
      children: List.generate(
        totalSegments,
        (index) => Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index < totalSegments - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: index < filledSegments ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
