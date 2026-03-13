import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';
import 'widgets/map_legend.dart';
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
  bool _panelExpanded = true;

  String _normalizeKey(String? value) {
    return value?.toString().trim().toLowerCase() ?? '';
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
      if (previous?.isVerifying == true && !next.isVerifying && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Location verified successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    final explorationState = ref.watch(explorationProvider);
    final assignments = explorationState.assignments;
    final lockedDistricts = assignments
        .where((assignment) => assignment.unlockedAt == null)
        .map((assignment) => assignment.district)
        .toSet();

    final selectedAssignment = assignments.firstWhere(
      (assignment) =>
          _normalizeKey(assignment.district) == _normalizeKey(selectedDistrict),
      orElse: () => DistrictAssignment(
        district: selectedDistrict ?? '',
        province: selectedProvince ?? '',
        assignedCount: 0,
        visitedCount: 0,
        unlockedAt: null,
        locations: const <ExplorationLocation>[],
      ),
    );

    final districtLocked = selectedDistrict == null
        ? false
        : lockedDistricts
              .map(_normalizeKey)
              .contains(_normalizeKey(selectedDistrict));

    // Calculate district progress (0.0-1.0 for each district)
    final districtProgress = _calculateDistrictProgress(assignments);

    // Watch the global theme provider
    final mapThemeStr = ref.watch(themeProvider);
    final theme = (mapThemeStr == 'dark') 
        ? MapVisualTheme.dark() 
        : const MapVisualTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Discover Sri Lanka', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            CartoonMapCanvas(
              regions: sriLankaRegions,
              selectedRegionId: selectedProvince,
              selectedDistrictName: selectedDistrict,
              theme: theme,
              districtProgress: districtProgress,
              onDistrictSelected: (districtName, provinceName) {
                setState(() {
                  if (selectedDistrict == districtName) {
                    // Toggle off if same one tapped again
                    selectedDistrict = null;
                    selectedProvince = null;
                  } else {
                    selectedDistrict = districtName;
                    selectedProvince =
                        (provinceName != null && provinceName.isNotEmpty)
                        ? provinceName
                        : null;
                  }
                });
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _panelExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _DistrictActionPanel(
                  district: selectedDistrict,
                  province: selectedProvince,
                  locked: districtLocked,
                  isLoading: explorationState.isLoading,
                  assignedCount: selectedAssignment.assignedCount,
                  visitedCount: selectedAssignment.visitedCount,
                  locations: selectedAssignment.locations,
                  onVerifyLocation: (location) {
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
            // if (explorationState.isVerifying) const _VerificationOverlay(),
            // legend removed
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
  final bool isLoading;
  final int assignedCount;
  final int visitedCount;
  final List<ExplorationLocation> locations;
  final ValueChanged<ExplorationLocation> onVerifyLocation;

  const _DistrictActionPanel({
    required this.district,
    required this.province,
    required this.locked,
    required this.onToggle,
    required this.isLoading,
    required this.assignedCount,
    required this.visitedCount,
    required this.locations,
    required this.onVerifyLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = district ?? 'Select a district';
    final subtitle = district == null
        ? 'Tap a district to reveal quests'
        : 'Province: ${province ?? 'Unknown'}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withOpacity(0.5) 
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : AppColors.textMuted,
                          ),
                        ),
                        if (district != null) ...[
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: (visitedCount / (assignedCount > 0 ? assignedCount : 1)).clamp(0, 1),
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.white12 : AppColors.border,
                                  valueColor: AlwaysStoppedAnimation(isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                                ),
                              ),
                              if (visitedCount > 0)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)).withOpacity(0.05),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Exploration Progress',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isDark ? Colors.grey[500] : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '$visitedCount / $assignedCount',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onToggle,
                        icon: const Icon(Icons.unfold_less),
                        color: isDark ? Colors.white60 : AppColors.textMuted,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Collapse',
                      ),
                      if (district != null)
                        IconButton(
                          onPressed: () {
                            // Find the state and set selectedDistrict to null
                            final state = context.findAncestorStateOfType<_MapScreenState>();
                            state?.setState(() {
                              state.selectedDistrict = null;
                              state.selectedProvince = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          color: isDark ? Colors.white38 : AppColors.textMuted,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Clear Selection',
                        ),
                    ],
                  ),
                ],
              ),
              if (district != null) ...[
                const SizedBox(height: 16),
                _AssignedLocationList(
                  isLoading: isLoading,
                  locations: locations,
                  onVerify: onVerifyLocation,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedLocationList extends StatelessWidget {
  final bool isLoading;
  final List<ExplorationLocation> locations;
  final ValueChanged<ExplorationLocation> onVerify;

  const _AssignedLocationList({
    required this.isLoading,
    required this.locations,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669))),
        ),
      );
    }

    if (locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'No assigned locations yet.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey[500] : AppColors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        height: 130,
        child: ListView.separated(
          itemCount: locations.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final location = locations[index];
            return Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        location.visited ? Icons.check_circle : Icons.location_on,
                        color: location.visited
                            ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
                            : (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0891B2)),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location.name,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    location.type,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: isDark ? Colors.grey[400] : AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: location.visited
                          ? null
                          : () => onVerify(location),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        backgroundColor: location.visited
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)).withOpacity(0.1),
                        foregroundColor: location.visited
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: location.visited ? Colors.transparent : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)).withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        location.visited ? 'Visited' : 'Discovery',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// class _VerificationOverlay extends StatelessWidget {
// ... removed legacy overlay
// }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onToggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  locked ? Icons.lock_outline : Icons.explore_outlined,
                  size: 20,
                  color: locked ? Colors.white38 : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                ),
                const SizedBox(width: 10),
                Text(
                  district ?? 'Select Location',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.unfold_more, size: 20, color: isDark ? Colors.white60 : AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
