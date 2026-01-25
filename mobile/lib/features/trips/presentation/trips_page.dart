import 'package:flutter/material.dart';

/// Placeholder screen for Trips. Team can add list, filters, and trip detail navigation.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: const Center(
        child: Text(
          'Trips page placeholder\nAdd trip cards, filters, and navigation to trip details.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
