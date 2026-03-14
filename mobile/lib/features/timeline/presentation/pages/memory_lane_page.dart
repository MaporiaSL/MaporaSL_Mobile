import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/timeline_event.dart';
import '../providers/timeline_provider.dart';
import 'widgets/timeline_event_card.dart';
import 'widgets/timeline_line_painter.dart';

class MemoryLanePage extends ConsumerStatefulWidget {
  const MemoryLanePage({super.key});

  @override
  ConsumerState<MemoryLanePage> createState() => _MemoryLanePageState();
}

class _MemoryLanePageState extends ConsumerState<MemoryLanePage> {
  @override
  Widget build(BuildContext context) {
    final timelineAsyncValue = ref.watch(timelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Lane'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
            ],
          ),
        ),
        child: timelineAsyncValue.when(
          data: (events) {
            if (events.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTimelineList(events);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(error.toString()),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 80,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your journey hasn\'t started yet!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go verify your first visit or upload a photo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(timelineProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(timelineProvider.notifier).refresh();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(List<TimelineEvent> events) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(timelineProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final isFirst = index == 0;
          final isLast = index == events.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline indicator
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    painter: TimelineLinePainter(
                      isFirst: isFirst,
                      isLast: isLast,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getEventColor(event.type),
                          border: Border.all(
                            color: AppColors.background,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getEventColor(event.type).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            _getEventIcon(event.type),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Event Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: TimelineEventCard(event: event),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.visit:
        return AppColors.primary;
      case TimelineEventType.photo:
        return AppColors.secondary;
      case TimelineEventType.achievement:
        return AppColors.accent;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getEventIcon(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.visit:
        return Icons.location_on;
      case TimelineEventType.photo:
        return Icons.camera_alt;
      case TimelineEventType.achievement:
        return Icons.star;
      default:
        return Icons.circle;
    }
  }
}
