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
  bool _panelExpanded = true;

  bool _isLocked(String? district) {
    if (district == null) return false;
    return _lockedDistricts.contains(district);
  }

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
    final districtLocked = _isLocked(selectedDistrict);
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
            Positioned(
              top: 16,
              right: 16,
              child: IgnorePointer(
                child: _HudCard(level: 7, xp: 320, nextLevelXp: 500),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _panelExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _DistrictActionPanel(
                  district: selectedDistrict,
                  province: selectedProvince,
                  locked: districtLocked,
                  onToggle: () {
                    setState(() => _panelExpanded = !_panelExpanded);
                  },
                ),
                secondChild: _CollapsedPanel(
                  district: selectedDistrict,
                  locked: districtLocked,
                  onToggle: () {
                    setState(() => _panelExpanded = !_panelExpanded);
                  },
                ),
              ),
            ),
            if (selectedProvince != null || selectedDistrict != null)
              Positioned(
                top: 16,
                left: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: districtLocked
                            ? Colors.redAccent.withOpacity(0.6)
                            : Colors.cyanAccent.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          districtLocked ? Icons.lock : Icons.explore,
                          size: 16,
                          color: districtLocked
                              ? Colors.redAccent
                              : Colors.cyanAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedProvince ?? selectedDistrict ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _HudCard extends StatelessWidget {
  final int level;
  final int xp;
  final int nextLevelXp;

  const _HudCard({
    required this.level,
    required this.xp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (xp / nextLevelXp).clamp(0.0, 1.0);
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1C2E).withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explorer Lv.$level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.cyanAccent.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$xp / $nextLevelXp XP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistrictActionPanel extends StatelessWidget {
  final String? district;
  final String? province;
  final bool locked;
  final VoidCallback onToggle;

  const _DistrictActionPanel({
    required this.district,
    required this.province,
    required this.locked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final title = district ?? 'Select a district';
    final subtitle = district == null
        ? 'Tap a district to reveal quests and rewards'
        : (province == null ? 'Unknown province' : 'Province: $province');

    return AnimatedOpacity(
      opacity: district == null ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1524).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked
                ? Colors.redAccent.withOpacity(0.5)
                : Colors.cyanAccent.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: locked
                      ? [Colors.redAccent, Colors.deepOrangeAccent]
                      : [Colors.cyanAccent, Colors.blueAccent],
                ),
              ),
              child: Icon(
                locked ? Icons.lock : Icons.shield_moon,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  color: Colors.white.withOpacity(0.7),
                  tooltip: 'Minimize',
                ),
                const SizedBox(height: 2),
                ElevatedButton.icon(
                  onPressed: district == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                locked
                                    ? 'District locked. Complete quests to unlock.'
                                    : 'Quest board opened for $title',
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.flag, size: 16),
                  label: const Text('Quests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: locked
                        ? Colors.redAccent
                        : Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: district == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tracking $title')),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedPanel extends StatelessWidget {
  final String? district;
  final bool locked;
  final VoidCallback onToggle;

  const _CollapsedPanel({
    required this.district,
    required this.locked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1524).withOpacity(0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: locked
                  ? Colors.redAccent.withOpacity(0.4)
                  : Colors.cyanAccent.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked ? Icons.lock : Icons.explore,
                size: 16,
                color: locked ? Colors.redAccent : Colors.cyanAccent,
              ),
              const SizedBox(width: 8),
              Text(
                district ?? 'Map Actions',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_up,
                size: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
