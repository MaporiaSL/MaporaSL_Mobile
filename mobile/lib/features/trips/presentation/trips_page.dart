import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/local_places_provider.dart';
import 'providers/trips_provider.dart';
import 'memory_lane_page.dart';
import 'create_trip_page.dart';
import 'widgets/explorer_stats_card.dart';
import 'widgets/trips_debug_panel.dart';

/// Trip Planning Hub - plan custom trips or start curated adventures, plus view explorer stats.
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

/// Legacy entry point retained for existing navigation usages.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) => const TripsScreen();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  final _planningScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load trips on init
    Future.microtask(() => ref.read(tripsProvider.notifier).loadTrips());
  }

  @override
  void dispose() {
    _planningScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localPlacesAsync = ref.watch(localPlacesWithDistanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planning'),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Dev Tools',
            onPressed: () => showTripsDebugPanel(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(localPlacesProvider);
          await ref.read(localPlacesProvider.future);
        },
        child: _buildTripPlanningTab(localPlacesAsync),
      ),
    );
  }

  Widget _buildTripPlanningTab(
    AsyncValue<List<PlaceWithDistance>> localPlacesAsync,
  ) {
    return localPlacesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return const Center(
            child: Text('More curated adventures coming soon'),
          );
        }
        return ListView.separated(
          controller: _planningScroll,
          padding: const EdgeInsets.all(16),
          itemCount: places.length + 2, // Button + Header + Places
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton.icon(
                  onPressed: _showCreateCustomTripForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Custom Trip'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              );
            }
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'TOP CURATED ADVENTURES',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                ),
              );
            }
            final item = places[index - 2];
            return _CuratedPlaceCard(item: item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading adventures: $err')),
    );
  }
  void _showCreateCustomTripForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTripPage()),
    );
  }
}

class _CuratedPlaceCard extends StatelessWidget {
  final PlaceWithDistance item;

  const _CuratedPlaceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final place = item.place;
    final distanceText =
        item.distanceKm != null
            ? '${item.distanceKm!.toStringAsFixed(1)} km away'
            : 'Distance unknown';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Show preview or details
        },
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey.shade200,
                  child:
                      place.photos.isNotEmpty
                          ? Image.network(
                            place.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          )
                          : const Icon(Icons.place, size: 32),
                ),
              ),
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        distanceText,
                        style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.description ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


