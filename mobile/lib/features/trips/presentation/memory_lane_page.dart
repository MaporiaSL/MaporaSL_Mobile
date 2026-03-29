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

class _MemoryLanePageState extends ConsumerState<MemoryLanePage> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JOURNEY TIMELINE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
            Text('Your past and future adventures', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 40),
          labelColor: colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.white24 : Colors.black26,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 11),
          tabs: const [
            Tab(text: 'MY TRIPS'),
            Tab(text: 'QUEST LOG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _TripsTimelineView(),
          const _QuestLogView(),
        ],
      ),
    );
  }
}

class _TripsTimelineView extends ConsumerWidget {
  const _TripsTimelineView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tripsState.isLoading && tripsState.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripsState.trips.isEmpty) {
      return _buildEmptyState(context, Ionicons.trail_sign_outline, 'No trips in your timeline', 'Start your story by mapping a plan!');
    }

    final sortedTrips = List<TripModel>.from(tripsState.trips);
    sortedTrips.sort((a, b) => b.startDate.compareTo(a.startDate));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: sortedTrips.length,
      itemBuilder: (context, index) {
        final trip = sortedTrips[index];
        return _TimelineItem(trip: trip, isLast: index == sortedTrips.length - 1);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12)),
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
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor, border: Border.all(color: dotColor.withOpacity(0.3), width: 4)),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: dotColor.withOpacity(0.15))),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripPage(trip: trip))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(trip.title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, letterSpacing: 1))),
                          _StatusBadge(isDone: isDone),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Ionicons.calendar_outline, size: 12, color: isDark ? Colors.white24 : Colors.black26),
                          const SizedBox(width: 4),
                          Text(DateFormat('MMM dd, yyyy').format(trip.startDate), style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (trip.locations != null && trip.locations!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: trip.locations!.take(3).map((l) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(4)),
                            child: Text(l.name, style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final newStatus = isDone ? 'planned' : 'completed';
                              await ref.read(tripsProvider.notifier).updateStatus(trip.id, newStatus);
                              ref.invalidate(tripsStatsProvider);
                            },
                            // FIXED: black30/white30 -> withOpacity(0.3)
                            child: Text(isDone ? 'REOPEN' : 'MARK DONE', style: TextStyle(color: isDone ? (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)) : Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                          IconButton(icon: const Icon(Ionicons.trash_outline, size: 16, color: Colors.redAccent), onPressed: () => ref.read(tripsProvider.notifier).deleteTrip(trip.id)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(isDone ? 'COMPLETED' : 'PLANNED', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

    // FIXED: Flattening district assignments into individual quests
    final allQuests = explorationState.assignments.expand((a) => a.locations.map((l) => (location: l, district: a.district))).toList();

    if (allQuests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Ionicons.sparkles_outline, size: 48, color: isDark ? Colors.white10 : Colors.black12),
             const SizedBox(height: 16),
             Text('No active quests', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allQuests.length,
      itemBuilder: (context, index) {
        final q = allQuests[index];
        final quest = q.location;
        final district = q.district;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Ionicons.map, color: Colors.amber, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIXED: placeName -> name
                    Text(quest.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                    Text(district, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // FIXED: isCompleted -> visited
              Text(quest.visited ? 'VERIFIED' : 'ACTIVE', style: TextStyle(color: quest.visited ? Colors.green : Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
