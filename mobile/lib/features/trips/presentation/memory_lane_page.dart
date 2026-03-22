import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/trip_model.dart';
import '../../exploration/providers/exploration_provider.dart';
import 'widgets/quest_card.dart';
import 'providers/trips_provider.dart';
import 'create_trip_page.dart';
import 'trip_detail_page.dart';
import '../../../core/constants/app_colors.dart';

/// Memory Lane - timeline of user trips with status-based grouping
class MemoryLanePage extends ConsumerStatefulWidget {
  const MemoryLanePage({super.key});

  @override
  ConsumerState<MemoryLanePage> createState() => _MemoryLanePageState();
}

class _MemoryLanePageState extends ConsumerState<MemoryLanePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Future.microtask(() {
      ref.read(tripsProvider.notifier).loadTrips();
      ref.read(explorationProvider.notifier).loadAssignments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests & Trips'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Quests'),
            Tab(text: 'Trips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(context),
          _buildTripsTab(context, tripsState),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(BuildContext context) {
    final explorationState = ref.watch(explorationProvider);

    if (explorationState.isLoading && explorationState.assignments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (explorationState.error != null &&
        explorationState.assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(explorationState.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(explorationProvider.notifier).loadAssignments(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final timelineItems = explorationState.assignments;

    if (timelineItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(explorationProvider.notifier).loadAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timelineItems.length,
        itemBuilder: (context, index) {
          return QuestCard(assignment: timelineItems[index]);
        },
      ),
    );
  }

  Widget _buildTripsTab(BuildContext context, TripsState tripsState) {
    if (tripsState.isLoading && tripsState.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(tripsState.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(tripsProvider.notifier).loadTrips(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final apiTrips = tripsState.trips;

    // Group API trips by status
    List<TripModel> byStatus(String key) => apiTrips.where((t) {
      final s = _statusKey(t);
      return s == key;
    }).toList();

    final scheduled = byStatus('scheduled');
    final planned = byStatus('planned') + byStatus('active');
    final apiCompleted = byStatus('completed');

    if (apiTrips.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(tripsProvider.notifier).loadTrips(refresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (scheduled.isNotEmpty)
            _StatusSection(
              label: 'Scheduled',
              color: Colors.blue,
              icon: Icons.calendar_today,
              trips: scheduled,
              canEdit: true,
            ),
          if (scheduled.isNotEmpty) const SizedBox(height: 24),
          if (planned.isNotEmpty)
            _StatusSection(
              label: 'Planned / Active',
              color: Colors.green,
              icon: Icons.route,
              trips: planned,
              canEdit: true,
            ),
          if (planned.isNotEmpty) const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The large research/magnifying glass icon from the screenshot
          Icon(
            Icons.manage_search_rounded,
            size: 100,
            color: Colors.blue.shade700.withOpacity(0.3), // Matches nav bar color
          ),
          const SizedBox(height: 16),
          const Text(
            'No trips yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start planning your adventure!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTripPage()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Create Trip',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Use brand primary color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _statusKey(TripModel trip) {
    if (trip.status != null) return trip.status!;
    switch (trip.timelineStatus) {
      case TripStatus.upcoming:
        return 'planned';
      case TripStatus.active:
        return 'active';
      case TripStatus.completed:
        return 'completed';
    }
  }
}

class _StatusSection extends ConsumerWidget {
  final String label;
  final Color color;
  final IconData icon;
  final List<TripModel> trips;
  final bool canEdit;

  const _StatusSection({
    required this.label,
    required this.color,
    required this.icon,
    required this.trips,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${trips.length}'),
              backgroundColor: color.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...trips.map(
          (trip) => _TripCard(
            trip: trip,
            color: color,
            canEdit: canEdit,
            onEdit: canEdit
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTripPage(trip: trip),
                      ),
                    );
                  }
                : null,
            onView: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
              );
            },
            onDelete: canEdit ? () => _confirmDelete(context, ref, trip) : null,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text('Are you sure you want to delete "${trip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(tripsProvider.notifier).deleteTrip(trip.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Trip deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final Color color;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback onView;
  final VoidCallback? onDelete;

  const _TripCard({
    required this.trip,
    required this.color,
    required this.canEdit,
    required this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final durationDays =
        trip.endDate.difference(trip.startDate).inDays.clamp(0, 999) + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateRange(trip.startDate, trip.endDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$durationDays',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'days',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trip.description != null && trip.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  trip.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (trip.locations != null && trip.locations!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: trip.locations!.take(3).map((loc) {
                    return Chip(label: Text(loc.name));
                  }).toList(),
                ),
              ),
            if (trip.completionPercentage > 0 || !canEdit) ...[
              const SizedBox(height: 10),
              _buildProgressBar(context),
            ],
            const SizedBox(height: 12),
            // Completed trips get the prominent detail button
            if (!canEdit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text(
                    'See Trip Progress & Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB020),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete'),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _dateRange(DateTime start, DateTime end) {
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  Widget _buildProgressBar(BuildContext context) {
    final pct = trip.completionPercentage;
    Color barColor;
    String label;
    if (pct >= 100) {
      barColor = const Color(0xFF1F8A70);
      label = '✅ Fully Completed';
    } else if (pct >= 75) {
      barColor = const Color(0xFF00A6B2);
      label = '🔥 Nearly There';
    } else if (pct >= 50) {
      barColor = const Color(0xFFFFB020);
      label = '⚡ Halfway Done';
    } else {
      barColor = const Color(0xFF1F6F8B);
      label = '🗺️ In Progress';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
            Text(
              '$pct%  •  ${trip.visitedCount}/${trip.destinationCount} spots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct / 100.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.black.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              );
            },
          ),
        ),
      ],
    );
  }
}

