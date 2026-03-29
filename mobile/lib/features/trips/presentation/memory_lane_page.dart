import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';

import '../data/models/trip_model.dart';
import '../../exploration/providers/exploration_provider.dart';
import 'providers/trips_provider.dart';
import 'providers/trips_stats_provider.dart';
import 'create_trip_page.dart';

class MemoryLanePage extends ConsumerStatefulWidget {
  const MemoryLanePage({super.key});

  @override
  ConsumerState<MemoryLanePage> createState() => _MemoryLanePageState();
}

class _MemoryLanePageState extends ConsumerState<MemoryLanePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(tripsStatsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Atmospheric Background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary.withOpacity(
                              isDark ? 0.05 : 0.02,
                            ),
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPEDITION HUB',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              fontSize: 20,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Archives of your global footprint',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          statsAsync.when(
                            data: (stats) => _buildHeroStats(context, stats),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : Colors.black87,
                  unselectedLabelColor: isDark
                      ? Colors.white24
                      : Colors.black26,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                  tabs: const [
                    Tab(text: 'JOURNEYS'),
                    Tab(text: 'MISSIONS'),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [const _TripsTimelineView(), const _QuestLogView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats(BuildContext context, dynamic stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _statBox(
          context,
          'CHAPTERS',
          stats.totalTrips.toString(),
          Icons.auto_stories,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _statBox(
          context,
          'GRID COVERAGE',
          '${stats.completionPercentage}%',
          Icons.grid_view_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _statBox(
          context,
          'VERIFIED GEMS',
          stats.totalVisited.toString(),
          Icons.diamond_outlined,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _statBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.7)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white24 : Colors.black26,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsTimelineView extends StatefulWidget {
  const _TripsTimelineView({super.key});

  @override
  State<_TripsTimelineView> createState() => _TripsTimelineViewState();
}

class _TripsTimelineViewState extends State<_TripsTimelineView> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final tripsState = ref.watch(tripsProvider);

              if (tripsState.isLoading && tripsState.trips.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredTrips = _filterTrips(tripsState.trips);

              if (filteredTrips.isEmpty) {
                return _buildEmptyState(context, ref, _activeFilter);
              }

              final sortedTrips = List<TripModel>.from(filteredTrips);
              sortedTrips.sort((a, b) => b.startDate.compareTo(a.startDate));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                itemCount: sortedTrips.length,
                itemBuilder: (context, index) {
                  final trip = sortedTrips[index];
                  return _TimelineItem(
                    trip: trip,
                    isLast: index == sortedTrips.length - 1,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Upcoming', 'Completed', 'Canceled'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _activeFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _activeFilter = filter;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: primary.withOpacity(0.2),
              side: BorderSide(
                color: isSelected
                    ? primary
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? primary
                    : (isDark ? Colors.white38 : Colors.black38),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  List<TripModel> _filterTrips(List<TripModel> trips) {
    if (_activeFilter == 'All') return trips;

    return trips.where((trip) {
      final status = trip.status;
      switch (_activeFilter) {
        case 'Upcoming':
          return status == 'planned';
        case 'Completed':
          return status == 'completed';
        case 'Canceled':
          return status == 'canceled';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, String filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.trail_sign_outline,
            size: 64,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'All' ? 'No journeys found' : 'No $filter journeys',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends ConsumerWidget {
  final TripModel trip;
  final bool isLast;
  const _TimelineItem({required this.trip, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDone = trip.status == 'completed';
    final isDark = theme.brightness == Brightness.dark;
    final dotColor = isDone ? Colors.green : theme.colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPathVisual(isDone, dotColor, isLast),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Dismissible(
                key: Key('trip_${trip.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(tripsProvider.notifier).deleteTrip(trip.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'JOURNEY "${trip.title.toUpperCase()}" DELETED',
                      ),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          // Undo logic if needed
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Ionicons.trash_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateTripPage(trip: trip),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                trip.title.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _StatusBadge(isDone: isDone),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMMM yyyy',
                          ).format(trip.startDate).toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white24 : Colors.black26,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (trip.locations != null &&
                            trip.locations!.isNotEmpty)
                          _buildNodeSummary(context, trip.locations!),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final newStatus = isDone
                                    ? 'planned'
                                    : 'completed';
                                await ref
                                    .read(tripsProvider.notifier)
                                    .updateStatus(trip.id, newStatus);
                                ref.invalidate(tripsStatsProvider);
                              },
                              child: Text(
                                isDone ? 'REOPEN MISSION' : 'FINALIZE JOURNEY',
                                style: TextStyle(
                                  color: isDone
                                      ? (isDark
                                            ? Colors.white24
                                            : Colors.black26)
                                      : Colors.green,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Ionicons.trash_outline,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => ref
                                  .read(tripsProvider.notifier)
                                  .deleteTrip(trip.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathVisual(bool isDone, Color color, bool isLast) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: color.withOpacity(0.2), width: 5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.5), color.withOpacity(0.05)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeSummary(BuildContext context, List<dynamic> locations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          Ionicons.location_outline,
          size: 12,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            locations.map((l) => l.name).join(' → '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isDone;
  const _StatusBadge({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final color = isDone ? Colors.green : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone) ...[
            const Icon(
              Ionicons.shield_checkmark,
              size: 10,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            isDone ? 'VERIFIED' : 'UPCOMING',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestLogView extends ConsumerWidget {
  const _QuestLogView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explorationState = ref.watch(explorationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (explorationState.isLoading && explorationState.assignments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (explorationState.assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.sparkles_outline,
              size: 48,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No active missions found',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: explorationState.assignments.length,
      itemBuilder: (context, index) {
        final assignment = explorationState.assignments[index];
        final district = assignment.district.toUpperCase();
        final locations = assignment.locations;
        final verifiedCount = locations.where((l) => l.visited).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.folder_open_outline,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              title: Text(
                district,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              subtitle: Text(
                '$verifiedCount/${locations.length} NODES VERIFIED',
                style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              trailing: Icon(
                Ionicons.chevron_down_outline,
                size: 16,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: locations
                  .map((quest) => _buildQuestSubItem(context, quest))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestSubItem(BuildContext context, dynamic quest) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = quest.visited ? Colors.green : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            quest.visited
                ? Ionicons.checkmark_circle
                : Ionicons.ellipse_outline,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quest.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            quest.visited ? 'VERIFIED' : 'ACTIVE',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
