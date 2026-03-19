import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/preplanned_trip_model.dart';
import '../../data/models/trip_model.dart';
import '../providers/trips_provider.dart';
import '../../../places/widgets/destination_picker.dart';

class PrePlannedTripDetailSheet extends ConsumerStatefulWidget {
  final PrePlannedTripModel trip;
  const PrePlannedTripDetailSheet({super.key, required this.trip});

  @override
  ConsumerState<PrePlannedTripDetailSheet> createState() => _PrePlannedTripDetailSheetState();
}

class _PrePlannedTripDetailSheetState extends ConsumerState<PrePlannedTripDetailSheet> {
  final bool _isCloning = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = widget.trip;
    final itinerary = trip.itinerary ?? {};
    final days = itinerary.keys.toList()..sort();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.district ?? 'Sri Lanka',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      _infoBadge(Icons.timer_outlined, '${trip.durationDays} Days', Colors.orange),
                      const SizedBox(width: 8),
                      _infoBadge(Icons.bolt, '${trip.xpReward} XP', Colors.purple),
                      const SizedBox(width: 8),
                      _infoBadge(Icons.signal_cellular_alt, trip.difficulty, Colors.green),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Daily Itinerary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...days.map((dayKey) {
                    final dayNum = dayKey.replaceAll('day_', '');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                dayNum,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DAY $dayNum',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  itinerary[dayKey] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Action Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isCloning ? null : () => _showQuickStartDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCloning
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Start This Adventure',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuickStartDialog(BuildContext context, WidgetRef ref) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
    final locationCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final calculatedEndDate = selectedDate.add(Duration(days: widget.trip.durationDays));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Start ${widget.trip.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Just a few details before we pack your bags!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  
                  // Smart Starting Location
                  const Text('Starting Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            locationCtrl.text.isEmpty ? 'Search starting point...' : locationCtrl.text,
                            style: TextStyle(
                              color: locationCtrl.text.isEmpty ? Colors.grey.shade600 : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Select Starting Point'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: DestinationPicker(
                                    onDestinationSelected: (name) {
                                      setDialogState(() {
                                        locationCtrl.text = name;
                                      });
                                      Navigator.pop(context); // Close the search popup
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Start Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start Date', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.calendar_month, color: Colors.blue),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const Divider(),
                  
                  // Auto-calculated End Date Display
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End Date (Auto-Calculated)', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(calculatedEndDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    trailing: const Icon(Icons.flag_circle, color: Colors.green),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final finalLocation = locationCtrl.text.trim().isEmpty 
                        ? 'Current Location' 
                        : locationCtrl.text.trim();

                    Navigator.pop(dialogContext); 
                    _createAndSaveTrip(ref, selectedDate, calculatedEndDate, finalLocation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Adventure'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createAndSaveTrip(WidgetRef ref, DateTime start, DateTime end, String startingLocation) async {
    final now = DateTime.now();

    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startMidnight = DateTime(start.year, start.month, start.day);
    String status = startMidnight.isAfter(todayMidnight) ? 'scheduled' : 'planned';

    final newTrip = TripModel(
      id: now.millisecondsSinceEpoch.toString(),
      userId: 'user', 
      title: widget.trip.title,
      description: widget.trip.description,
      startDate: start,
      endDate: end,
      locations: [
        TripLocation(name: startingLocation, day: 1),
        if (widget.trip.district != null) TripLocation(name: widget.trip.district!, day: 1),
      ], 
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    try {
      ref.read(tripsProvider.notifier).upsertTrip(newTrip);
      await ref.read(tripsProvider.notifier).loadTrips(refresh: true);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Adventure added to My Trips successfully!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save trip: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

