import 'package:flutter/material.dart';

/// Placeholder screen for Shop. Team can add merch listings, bundles, and checkout integration.
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: const Center(
        child: Text(
          'Shop page placeholder\nAdd merch, bundles, and purchase flow.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
