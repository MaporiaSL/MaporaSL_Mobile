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
  String? selectedDistrict;
  String? selectedProvince;

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
        child: Stack(
          children: [
            CartoonMapCanvas(
              regions: sriLankaRegions,
              selectedRegionId: selectedProvince,
              selectedDistrictName: selectedDistrict,
              onDistrictSelected: (districtName, provinceName) {
                setState(() {
                  selectedDistrict = districtName;
                  selectedProvince =
                      (provinceName != null && provinceName.isNotEmpty)
                          ? provinceName
                          : null;
                });
              },
            ),
            if (selectedProvince != null || selectedDistrict != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedProvince ?? selectedDistrict ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
