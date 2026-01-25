import 'package:flutter/material.dart';

/// Empty state widget for when user has no trips
class EmptyTripsState extends StatelessWidget {
  final VoidCallback onCreateTrip;

  const EmptyTripsState({super.key, required this.onCreateTrip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon
            Icon(
              Icons.card_travel_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Start Your Journey',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'No adventures yet! Create your first trip and start exploring the world.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // CTA Button
            ElevatedButton.icon(
              onPressed: onCreateTrip,
              icon: const Icon(Icons.add),
              label: const Text('Create First Adventure'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
