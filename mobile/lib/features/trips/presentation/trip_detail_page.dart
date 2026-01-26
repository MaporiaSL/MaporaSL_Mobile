import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/trip_model.dart';

class TripDetailPage extends StatelessWidget {
  final TripModel trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          _StatusChip(trip: trip),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderSection(trip: trip),
          const SizedBox(height: 16),
          _ProgressSection(trip: trip),
          const SizedBox(height: 16),
          _LocationsSection(trip: trip),
          const SizedBox(height: 16),
          _MapPreviewPlaceholder(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final TripModel trip;
  const _HeaderSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${trip.statusEmoji} ${trip.statusLabel} • ${trip.durationDays} days',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              trip.dateRangeFormatted,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (trip.description != null && trip.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(trip.description!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final TripModel trip;
  const _ProgressSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    final pct = trip.completionPercentage;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Objectives cleared'),
                const Spacer(),
                Text('$pct%'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: pct / 100.0,
                color: pct >= 80
                    ? Colors.green
                    : pct >= 50
                    ? Colors.orange
                    : Colors.blue,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trip.objectivesText,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationsSection extends StatelessWidget {
  final TripModel trip;
  const _LocationsSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    final locations = trip.locations ?? const <String>[];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text('Locations (${locations.length})'),
              ],
            ),
            const SizedBox(height: 12),
            if (locations.isEmpty)
              Text(
                'No locations added yet',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...locations.map(
                (loc) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(loc),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Text(
          'Map preview coming soon',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TripModel trip;
  const _StatusChip({required this.trip});

  Color _color(TripStatus s) {
    switch (s) {
      case TripStatus.upcoming:
        return Colors.blue;
      case TripStatus.active:
        return Colors.orange;
      case TripStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(trip.timelineStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '${trip.statusEmoji} ${trip.statusLabel}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
