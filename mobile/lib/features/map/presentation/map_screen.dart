import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
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

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  String? selectedDistrict;
  String? selectedProvince;
  late final AnimationController _pulseController;
  Offset _parallax = Offset.zero;

  Offset _clampOffset(Offset value, double limit) {
    final dx = value.dx.clamp(-limit, limit).toDouble();
    final dy = value.dy.clamp(-limit, limit).toDouble();
    return Offset(dx, dy);
  }

  static const Set<String> _lockedDistricts = <String>{
    'Jaffna',
    'Kilinochchi',
    'Mullaitivu',
    'Mannar',
    'Vavuniya',
  };

  static const MapVisualTheme _mapTheme = MapVisualTheme(
    oceanColor: Color(0xFF071624),
    coastlineColor: Color(0x66FFFFFF),
    oceanGlowColor: Color(0x9931E6FF),
    provinceBorderColor: Color(0x88FFFFFF),
    districtBorderColor: Color(0x4C00E0FF),
    selectedDistrictBorderColor: Color(0xFFFFD34E),
    selectedProvinceBorderColor: Color(0xFF6FE7FF),
    runeGlowColor: Color(0xFF7CFFF6),
    extrusionSideColor: Color(0xFF1C130E),
    extrusionDepth: 12,
    shadowOffset: Offset(20, 26),
    shadowBlur: 20,
    rimLightColor: Color(0xCCFFFFFF),
    rimLightWidth: 2.2,
    fogOpacity: 0.86,
    fogShadowBlur: 14,
    lockedDistrictIds: _lockedDistricts,
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _parallax = _clampOffset(_parallax + details.delta, 40);
                });
              },
              onPanEnd: (_) {
                setState(() => _parallax = Offset.zero);
              },
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final tiltX = (_parallax.dy / 400).clamp(-0.08, 0.08);
                  final tiltY = (_parallax.dx / 400).clamp(-0.08, 0.08);

                  return Transform(
                    alignment: Alignment.center,
                    transform: vm.Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(tiltX)
                      ..rotateY(-tiltY)
                      ..translate(_parallax.dx * 0.2, _parallax.dy * 0.2),
                    child: CartoonMapCanvas(
                      regions: sriLankaRegions,
                      selectedRegionId: selectedProvince,
                      selectedDistrictName: selectedDistrict,
                      theme: _mapTheme,
                      pulseValue: _pulseController.value,
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
                  );
                },
              ),
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
