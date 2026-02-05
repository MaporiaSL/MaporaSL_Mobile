import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';
import 'theme/map_visual_theme.dart';

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

  static const MapVisualTheme _mapTheme = MapVisualTheme(
    oceanColor: Color.fromARGB(255, 0, 1, 2),
    coastlineColor: Color(0x66FFFFFF),
    provinceBorderColor: Color(0x99FFFFFF),
    districtBorderColor: Color.fromARGB(84, 247, 4, 4),
    selectedDistrictBorderColor: Color(0xFFFFC857),
    selectedProvinceBorderColor: Color(0xFF7AE1FF),
    labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      shadows: [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black87),
      ],
    ),
  );

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
              theme: _mapTheme,
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
