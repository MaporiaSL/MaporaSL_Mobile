import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';
import 'theme/map_visual_theme.dart';
import '../../exploration/providers/exploration_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../exploration/data/models/exploration_models.dart';
import '../../visits/presentation/widgets/dynamic_visit_sheet.dart';

/// Lightweight map screen displaying stylized Sri Lanka map with exploration assignments
class MapScreen extends ConsumerStatefulWidget {
  final String travelId;

  const MapScreen({super.key, required this.travelId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? selectedDistrict;
  String? selectedProvince;
  bool _isDistrictFocused = false;
  double _focusScale = 1.0;
  Offset _focusFraction = const Offset(0.5, 0.5);
  ExplorationLocation? _selectedLocation;

  String _normalizeKey(String? value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  Offset _latLngToCanvas(double latitude, double longitude, Size size) {
    const minLat = 5.9;
    const maxLat = 9.95;
    const minLon = 79.65;
    const maxLon = 81.95;

    final x = ((longitude - minLon) / (maxLon - minLon)) * size.width;
    final y = ((maxLat - latitude) / (maxLat - minLat)) * size.height;
    return Offset(x, y);
  }

  DistrictAssignment? _assignmentForDistrict(
    List<DistrictAssignment> assignments,
    String? district,
  ) {
    if (district == null || district.isEmpty) return null;
    final districtKey = _normalizeKey(district);
    for (final assignment in assignments) {
      if (_normalizeKey(assignment.district) == districtKey) {
        return assignment;
      }
    }
    return null;
  }

  /// Calculate district progress map from assignments (0.0-1.0 for each district)
  Map<String, double> _calculateDistrictProgress(
    List<DistrictAssignment> assignments,
  ) {
    final progress = <String, double>{};
    for (final assignment in assignments) {
      final percentage = assignment.assignedCount > 0
          ? assignment.visitedCount / assignment.assignedCount
          : 0.0;
      progress[assignment.district.toLowerCase().trim()] = percentage;
    }
    return progress;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(explorationProvider.notifier).loadAssignments();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ExplorationState>(explorationProvider, (previous, next) {
      // Show error messages
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Show success message when verification completes
      if (previous?.isVerifying == true &&
          !next.isVerifying &&
          next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('âœ… Location verified successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    final explorationState = ref.watch(explorationProvider);
    final assignments = explorationState.assignments;
    final selectedAssignment = _assignmentForDistrict(
      assignments,
      selectedDistrict,
    );
    final selectedLocations =
        selectedAssignment?.locations ?? const <ExplorationLocation>[];

    // Calculate district progress (0.0-1.0 for each district)
    final districtProgress = _calculateDistrictProgress(assignments);

    // Watch the global theme provider
    final mapThemeStr = ref.watch(themeProvider);
    final theme = (mapThemeStr == 'dark')
        ? MapVisualTheme.dark()
        : const MapVisualTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ðŸ—ºï¸ Discover Sri Lanka',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final focusPx = Offset(
              _focusFraction.dx * size.width,
              _focusFraction.dy * size.height,
            );
            final center = Offset(size.width / 2, size.height / 2);
            final scale = _isDistrictFocused ? _focusScale : 1.0;
            final tx = _isDistrictFocused
                ? center.dx - (focusPx.dx * scale)
                : 0.0;
            final ty = _isDistrictFocused
                ? center.dy - (focusPx.dy * scale)
                : 0.0;

            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  transformAlignment: Alignment.topLeft,
                  transform: Matrix4.identity()
                    ..translateByDouble(tx, ty, 0.0, 1.0)
                    ..scaleByDouble(scale, scale, 1.0, 1.0),
                  child: Stack(
                    children: [
                      CartoonMapCanvas(
                        regions: sriLankaRegions,
                        selectedRegionId: selectedProvince,
                        selectedDistrictName: selectedDistrict,
                        focusMode: _isDistrictFocused,
                        focusedDistrictName: selectedDistrict,
                        theme: theme,
                        districtProgress: districtProgress,
                        onDistrictSelected:
                            (
                              districtName,
                              provinceName,
                              tapFraction,
                              focusTarget,
                            ) {
                              setState(() {
                                if (districtName.isEmpty) {
                                  selectedDistrict = null;
                                  selectedProvince = null;
                                  _isDistrictFocused = false;
                                  _focusScale = 1.0;
                                  _selectedLocation = null;
                                  _focusFraction = const Offset(0.5, 0.5);
                                  return;
                                }

                                final sameDistrict =
                                    _normalizeKey(selectedDistrict) ==
                                    _normalizeKey(districtName);
                                if (sameDistrict && _isDistrictFocused) {
                                  selectedDistrict = null;
                                  selectedProvince = null;
                                  _isDistrictFocused = false;
                                  _focusScale = 1.0;
                                  _selectedLocation = null;
                                  _focusFraction = const Offset(0.5, 0.5);
                                  return;
                                }

                                selectedDistrict = districtName;
                                selectedProvince =
                                    (provinceName != null &&
                                        provinceName.isNotEmpty)
                                    ? provinceName
                                    : null;
                                _isDistrictFocused = true;
                                _focusScale =
                                    focusTarget?.suggestedScale ?? 2.15;
                                _selectedLocation = null;

                                if (focusTarget != null) {
                                  _focusFraction = focusTarget.centroidFraction;
                                } else {
                                  final assignment = _assignmentForDistrict(
                                    assignments,
                                    districtName,
                                  );
                                  if (assignment != null &&
                                      assignment.center != null) {
                                    final centerPx = _latLngToCanvas(
                                      assignment.center!.latitude,
                                      assignment.center!.longitude,
                                      size,
                                    );
                                    _focusFraction = Offset(
                                      (centerPx.dx / size.width).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      (centerPx.dy / size.height).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                    );
                                  } else {
                                    _focusFraction = tapFraction;
                                  }
                                }
                              });
                            },
                      ),
                      if (_isDistrictFocused && selectedLocations.isNotEmpty)
                        ...selectedLocations.map((location) {
                          final point = _latLngToCanvas(
                            location.latitude,
                            location.longitude,
                            size,
                          );
                          return Positioned(
                            left: point.dx - 16,
                            top: point.dy - 32,
                            child: Semantics(
                              label: '${location.name} marker',
                              button: true,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  setState(() {
                                    _selectedLocation = location;
                                  });
                                },
                                child: Icon(
                                  location.visited
                                      ? Icons.location_on
                                      : Icons.location_on_outlined,
                                  size: 32,
                                  color: location.visited
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                if (_isDistrictFocused)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _FocusHintBar(
                      district: selectedDistrict,
                      onRefresh: () => ref
                          .read(explorationProvider.notifier)
                          .loadAssignments(),
                      onExit: () {
                        setState(() {
                          selectedDistrict = null;
                          selectedProvince = null;
                          _isDistrictFocused = false;
                          _focusScale = 1.0;
                          _selectedLocation = null;
                          _focusFraction = const Offset(0.5, 0.5);
                        });
                      },
                    ),
                  ),

                if (_selectedLocation != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _PlaceDetailCard(
                      location: _selectedLocation!,
                      onClose: () {
                        setState(() {
                          _selectedLocation = null;
                        });
                      },
                      onVerify: () {
                        final location = _selectedLocation;
                        if (location == null) return;
                        DynamicVisitSheet.show(
                          context,
                          placeId: location.id,
                          placeName: location.name,
                          targetLat: location.latitude,
                          targetLng: location.longitude,
                          isExploration: true,
                          explorationLocation: location,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FocusHintBar extends StatelessWidget {
  final String? district;
  final VoidCallback onRefresh;
  final VoidCallback onExit;

  const _FocusHintBar({
    required this.district,
    required this.onRefresh,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              district ?? 'District',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh assignments',
          ),
          IconButton(
            onPressed: onExit,
            icon: const Icon(Icons.close),
            tooltip: 'Exit district focus',
          ),
        ],
      ),
    );
  }
}

class _PlaceDetailCard extends StatelessWidget {
  final ExplorationLocation location;
  final VoidCallback onClose;
  final VoidCallback onVerify;

  const _PlaceDetailCard({
    required this.location,
    required this.onClose,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = location.photos.isNotEmpty ? location.photos.first : null;
    return Semantics(
      label: 'Place details for ${location.name}',
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackHeader(),
                ),
              )
            else
              _fallbackHeader(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(location.type.isEmpty ? 'Attraction' : location.type),
                  const SizedBox(height: 8),
                  Text(
                    location.description?.isNotEmpty == true
                        ? location.description!
                        : 'No description available yet. Visit this location to contribute better details.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: location.visited ? null : onVerify,
                      icon: const Icon(Icons.verified),
                      label: Text(
                        location.visited
                            ? 'Already Verified'
                            : 'Verify This Place',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(Icons.photo, size: 40, color: Color(0xFF64748B)),
      ),
    );
  }
}
