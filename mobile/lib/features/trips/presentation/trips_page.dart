import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/trip_model.dart';
import '../data/models/preplanned_trip_model.dart';
import 'providers/preplanned_trips_provider.dart';
import 'providers/trips_filter_provider.dart';
import 'providers/trips_provider.dart';
import 'trip_detail_page.dart';
import 'memory_lane_page.dart';
import 'widgets/adventure_trip_card.dart';
import 'widgets/empty_trips_state.dart';
import 'widgets/explorer_stats_card.dart';
import 'widgets/filter_chips.dart';
import 'widgets/trips_debug_panel.dart';

/// Adventures Hub with My Journeys | Discover toggle
class AdventuresHubScreen extends ConsumerStatefulWidget {
  const AdventuresHubScreen({super.key});

  @override
  ConsumerState<AdventuresHubScreen> createState() =>
      _AdventuresHubScreenState();
}

/// Legacy entry point retained for existing navigation usages
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) => const AdventuresHubScreen();
}

class _AdventuresHubScreenState extends ConsumerState<AdventuresHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _myJourneysScroll = ScrollController();
  final _discoverScroll = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(() => setState(() {}));

    // Load trips on init
    Future.microtask(() => ref.read(tripsProvider.notifier).loadTrips());

    // Setup infinite scroll for My Journeys
    _myJourneysScroll.addListener(_onScrollMyJourneys);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _myJourneysScroll.dispose();
    _discoverScroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScrollMyJourneys() {
    if (_myJourneysScroll.position.pixels >=
        _myJourneysScroll.position.maxScrollExtent * 0.8) {
      ref.read(tripsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsProvider);
    final filteredTrips = ref.watch(filteredTripsProvider);
    final isDiscover = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(isDiscover),
        actions: _buildActions(isDiscover),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Journeys'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(preplannedTripsFutureProvider);
              await ref.read(preplannedTripsFutureProvider.future);
            },
            child: _buildDiscoverTab(),
          ),
          RefreshIndicator(
            onRefresh: () =>
                ref.read(tripsProvider.notifier).loadTrips(refresh: true),
            child: _buildMyJourneys(tripsState, filteredTrips),
          ),
        ],
      ),
      floatingActionButton: !isDiscover
          ? FloatingActionButton.extended(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.explore),
              label: const Text('Plan New Trip'),
            )
          : null,
    );
  }

  Widget _buildTitle(bool isDiscover) {
    if (isDiscover) return const Text('Discover Adventures');
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search your journeys...',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          ref.read(tripSearchProvider.notifier).state = value;
        },
      );
    }
    return const Text('My Journeys');
  }

  List<Widget> _buildActions(bool isDiscover) {
    return [
      IconButton(
        icon: const Icon(Icons.timeline),
        tooltip: 'Memory Lane',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MemoryLanePage()),
          );
        },
      ),
      if (!isDiscover)
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                ref.read(tripSearchProvider.notifier).state = '';
              }
            });
          },
        ),
      IconButton(
        icon: const Icon(Icons.bug_report),
        tooltip: 'Dev Tools',
        onPressed: () => showTripsDebugPanel(context),
      ),
    ];
  }

  Widget _buildMyJourneys(TripsState state, List<TripModel> filteredTrips) {
    if (state.isLoading && state.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(tripsProvider.notifier).loadTrips(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.trips.isEmpty) {
      return EmptyTripsState(onCreateTrip: () => _tabController.animateTo(0));
    }

    final active = filteredTrips
        .where((t) => t.status == TripStatus.active)
        .toList(growable: false);
    final planned = filteredTrips
        .where((t) => t.status == TripStatus.upcoming)
        .toList(growable: false);
    final completed = filteredTrips
        .where((t) => t.status == TripStatus.completed)
        .toList(growable: false);

    return CustomScrollView(
      controller: _myJourneysScroll,
      slivers: [
        const SliverToBoxAdapter(child: ExplorerStatsCard()),
        const SliverToBoxAdapter(child: FilterChips()),
        if (filteredTrips.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No trips found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or search',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (active.isNotEmpty) _buildSection('Active Quests', active),
          if (planned.isNotEmpty) _buildSection('Planned Adventures', planned),
          if (completed.isNotEmpty)
            _buildSection('Completed Journeys', completed),
        ],
        if (state.isLoading && state.trips.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  SliverList _buildSection(String title, List<TripModel> trips) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '$title (${trips.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        ...trips.map(
          (trip) => AdventureTripCard(
            trip: trip,
            onTap: () => _navigateToTripDetail(trip),
            onLongPress: () => _showTripActions(trip),
          ),
        ),
      ]),
    );
  }

  Widget _buildDiscoverTab() {
    final templatesAsync = ref.watch(preplannedTripsFutureProvider);
    final filters = ref.watch(preplannedFiltersProvider);

    return ListView(
      controller: _discoverScroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _DiscoverFilters(
          filters: filters,
          onChanged: (updated) =>
              ref.read(preplannedFiltersProvider.notifier).state = updated,
          onClear: () => ref.read(preplannedFiltersProvider.notifier).state =
              const PreplannedFilters(),
        ),
        const SizedBox(height: 12),
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No curated adventures found.'),
                ),
              );
            }
            return Column(
              children: templates
                  .map(
                    (tpl) => _TemplateCard(
                      template: tpl,
                      onStart: () => _startAdventure(tpl),
                      onPreview: () => _showTemplatePreview(tpl),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(err.toString()),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(preplannedTripsFutureProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startAdventure(PrePlannedTripModel template) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Choose your adventure dates',
    );

    if (range == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(
        startAdventureProvider(
          StartAdventureRequest(
            templateId: template.id,
            startDate: range.start,
            endDate: range.end,
          ),
        ).future,
      );
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Added to My Journeys: ${template.title}')),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to start adventure: $e')),
      );
    }
  }

  void _showTemplatePreview(PrePlannedTripModel template) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              template.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(template.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('${template.durationDays} days')),
                Chip(label: Text('${template.xpReward} XP')),
                Chip(label: Text(template.difficulty)),
                ...template.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Stops (${template.placeIds.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...template.placeIds.map(
              (p) => ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(p),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startAdventure(template);
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Start Adventure'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTripDetail(TripModel trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
    );
  }

  void _showTripActions(TripModel trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Trip'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit trip coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Trip',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await _confirmDelete(trip);
              if (confirm) {
                await ref.read(tripsProvider.notifier).deleteTrip(trip.id);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Trip deleted')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Trip'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(TripModel trip) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Trip?'),
            content: Text(
              'This will permanently delete "${trip.title}" and all its destinations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _DiscoverFilters extends StatelessWidget {
  final PreplannedFilters filters;
  final ValueChanged<PreplannedFilters> onChanged;
  final VoidCallback onClear;

  const _DiscoverFilters({
    required this.filters,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final durations = <String?>['1-3', '4-6', '7+'];
    final difficulties = <String?>['Easy', 'Moderate', 'Hard'];
    final starts = <String?>['Colombo', 'Kandy', 'Galle', 'Jaffna', 'Trinco'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...durations.map(
              (d) => FilterChip(
                label: Text(d ?? 'Any duration'),
                selected: filters.duration == d,
                onSelected: (_) => onChanged(filters.copyWith(duration: d)),
              ),
            ),
            ...difficulties.map(
              (d) => FilterChip(
                label: Text(d ?? 'Any difficulty'),
                selected: filters.difficulty == d,
                onSelected: (_) => onChanged(filters.copyWith(difficulty: d)),
              ),
            ),
            ...starts.map(
              (s) => FilterChip(
                label: Text(s ?? 'Any start'),
                selected: filters.startingPoint == s,
                onSelected: (_) =>
                    onChanged(filters.copyWith(startingPoint: s)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PrePlannedTripModel template;
  final VoidCallback onPreview;
  final VoidCallback onStart;

  const _TemplateCard({
    required this.template,
    required this.onPreview,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              template.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('${template.durationDays} days')),
                Chip(label: Text('${template.xpReward} XP')),
                Chip(label: Text(template.difficulty)),
                if (template.tags.isNotEmpty)
                  Chip(label: Text(template.tags.take(2).join(' • '))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Preview'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Start Adventure'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
