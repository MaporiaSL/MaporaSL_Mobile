import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/sample_trips_generator.dart';
import '../providers/trips_provider.dart';

/// Debug panel for testing trips functionality
class TripsDebugPanel extends ConsumerWidget {
  const TripsDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Developer Tools',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),

          // Generate Sample Trips Button
          ElevatedButton.icon(
            onPressed: () async {
              final notifier = ref.read(tripsProvider.notifier);
              final samples = SampleTripsGenerator.getSampleTrips();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Creating ${samples.length} sample trips...'),
                  duration: const Duration(seconds: 2),
                ),
              );

              int created = 0;
              for (final sample in samples) {
                try {
                  await notifier.createTrip(sample);
                  created++;
                } catch (e) {
                  debugPrint('Failed to create sample trip: $e');
                }
                // Small delay to avoid overwhelming the API
                await Future.delayed(const Duration(milliseconds: 300));
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Created $created sample trips!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate 10 Sample Trips'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 12),

          // Create Single Test Trip
          OutlinedButton.icon(
            onPressed: () async {
              final notifier = ref.read(tripsProvider.notifier);
              final testTrip = SampleTripsGenerator.getQuickTestTrip();

              try {
                await notifier.createTrip(testTrip);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Test trip created!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.science),
            label: const Text('Create Single Test Trip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 12),

          // Clear All Trips
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('⚠️ Clear All Trips?'),
                  content: const Text(
                    'This will delete all trips. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final notifier = ref.read(tripsProvider.notifier);
                        final currentTrips = ref.read(tripsProvider).trips;

                        for (final trip in currentTrips) {
                          try {
                            await notifier.deleteTrip(trip.id);
                          } catch (e) {
                            debugPrint('Failed to delete trip ${trip.id}: $e');
                          }
                        }

                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close debug panel
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🗑️ All trips cleared'),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('DELETE ALL'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear All Trips'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            '⚠️ Development tools only',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Show debug panel as bottom sheet
void showTripsDebugPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const TripsDebugPanel(),
  );
}
