import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/regions_data.dart';
import 'widgets/cartoon_map_canvas.dart';
import 'widgets/map_legend.dart';
import 'theme/map_visual_theme.dart';
import '../../exploration/providers/exploration_provider.dart';
import '../../exploration/data/models/exploration_models.dart';

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

  // Light theme map visual appearance with progressive unlock colors
  static const MapVisualTheme _mapTheme = MapVisualTheme();

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
      final error = next.error;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
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

    // Use the default light theme with progressive colors
    final theme = _mapTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Discover Sri Lanka'),
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
                  selectedDistrict = districtName;
                  selectedProvince =
                      (provinceName != null && provinceName.isNotEmpty)
                      ? provinceName
                      : null;
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
                    ref
                        .read(explorationProvider.notifier)
                        .verifyLocation(location);
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
            if (explorationState.isVerifying) const _VerificationOverlay(),
            // Map legend
            Positioned(
              top: 16,
              right: 16,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: const MapLegend(),
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
    final title = district ?? 'Select a district';
    final subtitle = district == null
        ? 'Tap a district to reveal quests'
        : 'Province: ${province ?? 'Unknown'}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (district != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value:
                                (visitedCount /
                                        (assignedCount > 0 ? assignedCount : 1))
                                    .clamp(0, 1),
                            minHeight: 4,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Progress: $visitedCount / $assignedCount',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: const Icon(Icons.unfold_less),
                  color: AppColors.textMuted,
                  tooltip: 'Collapse',
                ),
              ],
            ),
            if (district != null) ...[
              const SizedBox(height: 12),
              _AssignedLocationList(
                isLoading: isLoading,
                locations: locations,
                onVerify: onVerifyLocation,
              ),
            ],
          ],
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
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          itemCount: locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final location = locations[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(
                    location.visited ? Icons.check_circle : Icons.location_on,
                    color: location.visited
                        ? AppColors.success
                        : AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location.name,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          location.type,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: location.visited
                        ? null
                        : () => onVerify(location),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      backgroundColor: location.visited
                          ? AppColors.border
                          : AppColors.primary,
                      foregroundColor: location.visited
                          ? AppColors.textMuted
                          : Colors.white,
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.textMuted,
                    ),
                    child: Text(
                      location.visited ? 'Done' : 'Verify',
                      style: const TextStyle(fontSize: 11),
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

class _VerificationOverlay extends StatelessWidget {
  const _VerificationOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.background.withOpacity(0.95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 16),
            Text(
              'Verifying location...\nPlease stay still',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
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
    return GestureDetector(
      onTap: onToggle,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked ? Icons.lock : Icons.explore,
                size: 18,
                color: locked ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                district ?? 'Map',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.unfold_more, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
