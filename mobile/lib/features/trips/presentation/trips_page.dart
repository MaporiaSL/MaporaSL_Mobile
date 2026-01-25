import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/explorer_stats_card.dart';
import 'widgets/filter_chips.dart';
import 'widgets/adventure_trip_card.dart';
import 'widgets/empty_trips_state.dart';
import 'providers/trips_provider.dart';
import 'providers/trips_filter_provider.dart';

/// Main trips page - "Quest Log" for MAPORIA adventures
class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load trips on init
    Future.microtask(() => ref.read(tripsProvider.notifier).loadTrips());

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(tripsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsProvider);
    final filteredTrips = ref.watch(filteredTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search adventures...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(tripSearchProvider.notifier).state = value;
                },
              )
            : const Text('My Adventures'),
        actions: [
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(tripsProvider.notifier).loadTrips(refresh: true),
        child: _buildBody(tripsState, filteredTrips),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateTrip,
        icon: const Icon(Icons.add),
        label: const Text('New Adventure'),
      ),
    );
  }

  Widget _buildBody(TripsState state, List filteredTrips) {
    // Initial loading
    if (state.isLoading && state.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
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

    // Empty state
    if (state.trips.isEmpty) {
      return EmptyTripsState(onCreateTrip: _navigateToCreateTrip);
    }

    // Trips list
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Explorer stats header
        const SliverToBoxAdapter(child: ExplorerStatsCard()),

        // Filter chips
        const SliverToBoxAdapter(child: FilterChips()),

        // Trip cards
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
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final trip = filteredTrips[index];
              return AdventureTripCard(
                trip: trip,
                onTap: () => _navigateToTripDetail(trip.id),
                onLongPress: () => _showTripActions(trip),
              );
            }, childCount: filteredTrips.length),
          ),

        // Loading more indicator
        if (state.isLoading && state.trips.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  void _navigateToCreateTrip() {
    // TODO: Navigate to create trip page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create trip form coming soon!')),
    );
  }

  void _navigateToTripDetail(String tripId) {
    // TODO: Navigate to trip detail/map view
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening trip $tripId...')));
  }

  void _showTripActions(trip) {
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

  Future<bool> _confirmDelete(trip) async {
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
