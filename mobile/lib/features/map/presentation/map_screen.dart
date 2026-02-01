import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';

/// Cartoonish map screen displaying trip with stylized Sri Lanka map
class MapScreen extends ConsumerStatefulWidget {
  final String travelId;

  const MapScreen({super.key, required this.travelId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? selectedRegion;

  @override
  void initState() {
    super.initState();
    // TODO: Load trip data from API
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Discover Sri Lanka'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map feature coming soon!')),
              );
            },
            tooltip: 'Info',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Cartoonish map canvas
            Expanded(
              child: CartoonMapCanvas(
                regions: sriLankaRegions,
                selectedRegionId: selectedRegion,
                onRegionSelected: (regionId) {
                  setState(() => selectedRegion = regionId);
                },
              ),
            ),

            // Bottom info panel
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedRegion != null
                        ? 'Selected: $selectedRegion'
                        : 'Tap a region to start',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
