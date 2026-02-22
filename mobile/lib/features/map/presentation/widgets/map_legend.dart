import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Legend widget explaining map district colors and what they represent
class MapLegend extends StatelessWidget {
  final bool compact;

  const MapLegend({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'District Progress',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          _LegendItem(
            color: const Color(0xFFD4AF37), // Gold
            label: '100% Complete',
            subLabel: 'All places visited',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: const Color(0xFFE6C75B), // Light gold
            label: '75%+ Progress',
            subLabel: 'Nearly complete',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: const Color(0xFF4FD1D9), // Light teal
            label: '50%+ Progress',
            subLabel: 'Halfway there',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: const Color(0xFFC5D9E8), // Light slate
            label: '25%+ Progress',
            subLabel: 'Just started',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: const Color(0xFFE8EAED), // Very light grey
            label: 'Locked',
            subLabel: 'No progress yet',
          ),
        ],
      ),
    );
  }
}

/// Individual legend item showing color and label
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String? subLabel;

  const _LegendItem({required this.color, required this.label, this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF00A6B2), width: 0.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
