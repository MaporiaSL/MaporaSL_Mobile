import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'create_trip_page.dart';
import 'providers/trips_provider.dart';
import 'providers/trips_stats_provider.dart';
import 'providers/preplanned_trips_provider.dart';
import '../data/models/trip_model.dart';
import '../data/models/preplanned_trip_model.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(tripsProvider.notifier).loadTrips();
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
    final statsAsync = ref.watch(tripsStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                   // Background Glow
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary.withOpacity(0.1)),
                      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR ADVENTURES', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 16),
                          statsAsync.when(
                            data: (stats) => _buildMiniStats(stats),
                            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
              tabs: const [
                Tab(text: 'MY TRIPS'),
                Tab(text: 'DISCOVER'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MyTripsTab(),
            _DiscoverTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripPage())),
        icon: const Icon(Ionicons.add),
        label: const Text('PLAN TRIP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMiniStats(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBlock('VISITS', stats.totalVisited.toString(), Colors.cyan),
          _StatBlock('CONNECT', '${stats.completionPercentage}%', Colors.orange),
          _StatBlock('RANK', stats.levelTitle.split(' ')[0], Colors.purple),
        ],
      ),
    );
  }

  Widget _StatBlock(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }
}

class _MyTripsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);

    if (tripsState.isLoading && tripsState.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripsState.trips.isEmpty) {
      return _buildEmptyState(context, 'No trips planned yet.', 'Start by creating your own or discovering a plan.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: tripsState.trips.length,
      itemBuilder: (context, index) {
        final trip = tripsState.trips[index];
        return _TripCard(trip: trip);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.trail_sign_outline, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white24, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = trip.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(trip.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDone ? Colors.green : Colors.blue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: (isDone ? Colors.green : Colors.blue).withOpacity(0.3)),
                      ),
                      child: Text(isDone ? 'COMPLETED' : 'PLANNED', style: TextStyle(color: isDone ? Colors.green : Colors.blue, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Icon(Ionicons.calendar_outline, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text('${DateFormat('MMM dd').format(trip.startDate)}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(icon: const Icon(Ionicons.create_outline, color: Colors.white30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripPage(trip: trip)))),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final newStatus = isDone ? 'planned' : 'completed';
                    await ref.read(tripsProvider.notifier).updateStatus(trip.id, newStatus);
                    ref.invalidate(tripsStatsProvider);
                  },
                  icon: Icon(isDone ? Ionicons.refresh_outline : Ionicons.checkmark_circle, size: 16, color: isDone ? Colors.white38 : Colors.green),
                  label: Text(isDone ? 'REOPEN TRIP' : 'MARK AS DONE', style: TextStyle(color: isDone ? Colors.white38 : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Ionicons.trash_outline, size: 16, color: Colors.redAccent), onPressed: () => ref.read(tripsProvider.notifier).deleteTrip(trip.id)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preplannedAsync = ref.watch(preplannedTripsFutureProvider);

    return preplannedAsync.when(
      data: (templates) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return _TemplateCard(template: template);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading plans: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PrePlannedTripModel template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        image: template.imageUrl != null ? DecorationImage(image: NetworkImage(template.imageUrl!), fit: BoxFit.cover, opacity: 0.2) : null,
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripPage(initialDestinations: template.placeIds, trip: TripModel(
          id: '', userId: '', title: template.title, description: template.description, startDate: DateTime.now(), endDate: DateTime.now().add(Duration(days: template.durationDays)), createdAt: DateTime.now(), updatedAt: DateTime.now(),
        )))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('${template.durationDays} DAYS', style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Text('${template.xpReward} XP', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(template.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(template.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('GET THIS PLAN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(width: 8),
                  Icon(Ionicons.arrow_forward, size: 14, color: colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
