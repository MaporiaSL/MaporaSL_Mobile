import 'package:flutter/material.dart';

/// Placeholder screen for Album. Team can add photo grid, filters, and upload flow.
class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: const Center(
        child: Text(
          'Album page placeholder\nAdd photo grid, map pins, and upload actions.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
