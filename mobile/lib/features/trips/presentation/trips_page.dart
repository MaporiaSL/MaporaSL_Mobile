import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'create_trip_page.dart';
import 'providers/trips_provider.dart';
import 'providers/trips_stats_provider.dart';
import 'providers/preplanned_trips_provider.dart';
import '../../places/data/places_repository.dart';
import '../../places/presentation/add_destination_page.dart';
import '../../home/presentation/providers/home_providers.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tripsProvider.notifier).loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(tripsStatsProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
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
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary.withOpacity(0.08)),
                      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRIPS DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 16),
                          statsAsync.when(
                            data: (stats) => _buildStatsHero(context, stats),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle(context, 'QUICK MISSION TOOLS'),
                   const SizedBox(height: 16),
                   _buildToolsGrid(context),
                   const SizedBox(height: 32),
                   _buildSectionTitle(context, 'INSPIRED DISCOVERY'),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: _DiscoverList(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildStatsHero(BuildContext context, dynamic stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBlock(context, 'VISITS', stats.totalVisited.toString(), Colors.cyan),
          _StatBlock(context, 'CONNECT', '${stats.completionPercentage}%', Colors.orange),
          _StatBlock(context, 'RANK', stats.levelTitle.split(' ')[0], Colors.purple),
        ],
      ),
    );
  }

  Widget _StatBlock(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ToolCard(context, 'PLAN NEW', Ionicons.add_circle_outline, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripPage())))),
        const SizedBox(width: 12),
        Expanded(child: _ToolCard(context, 'BROWSE GEMS', Ionicons.search_outline, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDestinationPage())))),
        const SizedBox(width: 12),
        // FIXED: Use homeSelectedIndexProvider instead of DefaultTabController
        Expanded(child: _ToolCard(context, 'ACTIVE MAP', Ionicons.map_outline, Colors.orange, () => ref.read(homeSelectedIndexProvider.notifier).state = 2)),
      ],
    );
  }

  Widget _ToolCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _DiscoverList extends ConsumerWidget {
  const _DiscoverList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preplannedAsync = ref.watch(preplannedTripsFutureProvider);

    return preplannedAsync.when(
      data: (templates) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            return _TemplateCard(template: template);
          },
          childCount: templates.length,
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error loading plans: $e', style: const TextStyle(color: Colors.red)))),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final dynamic template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        image: template.imageUrl != null ? DecorationImage(image: NetworkImage(template.imageUrl!), fit: BoxFit.cover, opacity: 0.1) : null,
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripPage(initialDestinations: template.placeIds, trip: null))),
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
                    decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${template.durationDays} DAYS', style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Text('${template.xpReward} XP', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(template.title.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(template.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('LAUNCH MISSION', style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(width: 8),
                  Icon(Ionicons.rocket_outline, size: 14, color: colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
