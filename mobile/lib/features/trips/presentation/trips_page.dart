import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/local_places_provider.dart';
import 'providers/trips_provider.dart';
import 'create_trip_page.dart';
import 'trip_detail_page.dart';
import '../data/models/trip_model.dart';

/// Trip Planning Hub — split view: Pre-Planned (left) | Custom Trips (right)
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

class _TripsScreenState extends ConsumerState<TripsScreen>
    with SingleTickerProviderStateMixin {
  // 0 = Pre-planned, 1 = Custom
  int _activePanel = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tripsProvider.notifier).loadTrips());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Trip Planning'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // ===== SPLIT SELECTOR TABS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _PanelTab(
                    label: '🗺️ Pre-Planned',
                    subtitle: 'Curated adventures',
                    isActive: _activePanel == 0,
                    onTap: () => setState(() => _activePanel = 0),
                  ),
                  _PanelTab(
                    label: '✏️ My Trips',
                    subtitle: 'Custom journeys',
                    isActive: _activePanel == 1,
                    onTap: () => setState(() => _activePanel = 1),
                  ),
                ],
              ),
            ),
          ),

          // ===== PANEL CONTENT =====
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _activePanel == 0
                  ? _PrePlannedPanel(key: const ValueKey('preplanned'))
                  : _CustomTripsPanel(
                      key: const ValueKey('custom'),
                      onCreateTrip: _navigateToCreateTrip,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateTrip() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTripPage()),
    );
    // Refresh custom trips after returning
    if (mounted) {
      ref.read(tripsProvider.notifier).loadTrips(refresh: true);
      setState(() => _activePanel = 1); // Stay on My Trips panel
    }
  }
}

// ─────────────────────────────────────────────
// Panel Tab Toggle Button
// ─────────────────────────────────────────────
class _PanelTab extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _PanelTab({
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isActive
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive
                      ? colorScheme.onPrimary.withOpacity(0.8)
                      : colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LEFT PANEL: Pre-Planned Trips
// ─────────────────────────────────────────────
class _PrePlannedPanel extends ConsumerWidget {
  const _PrePlannedPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localPlacesAsync = ref.watch(localPlacesWithDistanceProvider);

    return localPlacesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No curated adventures yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(localPlacesProvider);
            await ref.read(localPlacesProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: places.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'CURATED ADVENTURES',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              letterSpacing: 1.1,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${places.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _CuratedPlaceCard(item: places[index - 1]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Failed to load adventures', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(localPlacesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RIGHT PANEL: Custom Trips
// ─────────────────────────────────────────────
class _CustomTripsPanel extends ConsumerWidget {
  final VoidCallback onCreateTrip;

  const _CustomTripsPanel({super.key, required this.onCreateTrip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);

    return Column(
      children: [
        // Create Trip Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCreateTrip,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Custom Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.luggage, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                'MY TRIPS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      letterSpacing: 1.1,
                    ),
              ),
              if (!tripsState.isLoading) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tripsState.trips.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Trip List
        Expanded(
          child: _buildTripsList(context, ref, tripsState),
        ),
      ],
    );
  }

  Widget _buildTripsList(BuildContext context, WidgetRef ref, TripsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(tripsProvider.notifier).loadTrips(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first custom trip!',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tripsProvider.notifier).loadTrips(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: state.trips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _CustomTripCard(trip: state.trips[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card: Curated Place (Pre-Planned)
// ─────────────────────────────────────────────
class _CuratedPlaceCard extends StatelessWidget {
  final PlaceWithDistance item;

  const _CuratedPlaceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final place = item.place;
    final distanceText = item.distanceKm != null
        ? '${item.distanceKm!.toStringAsFixed(1)} km away'
        : place.district ?? '';

    final categoryColor = _categoryColor(place.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              // Image
              SizedBox(
                width: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: categoryColor.withOpacity(0.15)),
                    place.photos.isNotEmpty
                        ? Image.network(
                            place.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _categoryIcon(place.category),
                              size: 40,
                              color: categoryColor,
                            ),
                          )
                        : Icon(
                            _categoryIcon(place.category),
                            size: 40,
                            color: categoryColor,
                          ),
                    // Category badge
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (place.category ?? 'place').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.blue.shade600),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              distanceText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String? category) {
    switch (category) {
      case 'beach': return Colors.cyan;
      case 'mountain': return Colors.green;
      case 'historical': return Colors.brown;
      case 'temple': return Colors.orange;
      case 'park': return Colors.lightGreen;
      case 'wildlife': return Colors.teal;
      case 'forest': return Colors.green.shade700;
      default: return Colors.blue;
    }
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'beach': return Icons.beach_access;
      case 'mountain': return Icons.landscape;
      case 'historical': return Icons.account_balance;
      case 'temple': return Icons.temple_buddhist;
      case 'park': return Icons.park;
      case 'wildlife': return Icons.pets;
      case 'forest': return Icons.forest;
      default: return Icons.place;
    }
  }
}

// ─────────────────────────────────────────────
// Card: Custom User Trip
// ─────────────────────────────────────────────
class _CustomTripCard extends StatelessWidget {
  final TripModel trip;

  const _CustomTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(trip.timelineStatus);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
          );
        },
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              // Status stripe
              Container(
                width: 6,
                color: statusColor,
              ),
              // Icon area
              Container(
                width: 100,
                color: statusColor.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(trip.statusEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Trip details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 11, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trip.dateRangeFormatted,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 11, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            trip.objectivesText,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: trip.completionRate,
                          backgroundColor: Colors.grey.shade200,
                          color: statusColor,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(TripStatus status) {
    switch (status) {
      case TripStatus.upcoming: return Colors.blue;
      case TripStatus.active: return Colors.green;
      case TripStatus.completed: return Colors.purple;
    }
  }
}
