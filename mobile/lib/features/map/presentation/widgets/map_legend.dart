import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';

/// Legend widget explaining map district colors and what they represent
class MapLegend extends StatelessWidget {
  final bool compact;

  const MapLegend({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'District Progress',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              _LegendItem(
                color: AppColors.neonLime,
                label: '100% Complete',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.neonCyan,
                label: '75%+ Progress',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.neonPurple,
                label: '25% - 75%',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.neonPink,
                label: 'Starting Out',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                label: 'Locked',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual legend item showing color and label
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({required this.color, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.grey[300] : AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}


