import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/xp_multiplier_provider.dart';

/// Widget displaying XP breakdown and multiplier information
class XPMultiplierStatusCard extends ConsumerWidget {
  final bool expanded;

  const XPMultiplierStatusCard({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xpMultiplierProvider);

    if (!expanded && state.currentComboCount == 0 && state.streakDays == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E40AF).withValues(alpha: 0.8),
            const Color(0xFF0F6F8E).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22D3EE).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combo Status
          if (state.currentComboCount > 0)
            _ComboStatusRow(
              comboCount: state.currentComboCount,
              comboStatus: state.comboStatus,
            ),

          if (state.currentComboCount > 0) const SizedBox(height: 8),

          // Streak Status
          if (state.streakDays > 0)
            _StreakStatusRow(
              streakDays: state.streakDays,
              streakDisplay: state.streakDisplay,
            ),

          if (state.streakDays > 0 && expanded) const SizedBox(height: 12),

          // Expanded view: Today's unlocks breakdown
          if (expanded && state.unlockedToday.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 12),
            const Text(
              'Today\'s Unlocks:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E7FF),
              ),
            ),
            const SizedBox(height: 8),
            ...state.unlockedToday.map(
              (unlock) => _UnlockBreakdownRow(unlock: unlock),
            ),
          ],

          // Session summary
          if (expanded && state.totalXpThisSession > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Session Total:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  Text(
                    '+${state.totalXpThisSession.toStringAsFixed(0)} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFCD34D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComboStatusRow extends StatelessWidget {
  final int comboCount;
  final String comboStatus;

  const _ComboStatusRow({required this.comboCount, required this.comboStatus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: comboCount >= 3
                ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                : const Color(0xFF3B82F6).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$comboCount/3 Combo',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            comboStatus,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFCD34D),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakStatusRow extends StatelessWidget {
  final int streakDays;
  final String streakDisplay;

  const _StreakStatusRow({
    required this.streakDays,
    required this.streakDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$streakDays Day Streak',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            streakDisplay,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFCD34D),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnlockBreakdownRow extends StatelessWidget {
  final XPUnlock unlock;

  const _UnlockBreakdownRow({required this.unlock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlock.districtName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  unlock.bonusBreakdown,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFCBD5E1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${unlock.finalXp.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFCD34D),
            ),
          ),
        ],
      ),
    );
  }
}

/// Combo indicator widget for success sheet
class ComboIndicator extends ConsumerWidget {
  const ComboIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xpMultiplierProvider);

    if (state.currentComboCount < 3) return const SizedBox.shrink();

    return Tooltip(
      message: 'You\'ve unlocked 3 places today! Earning 2x XP bonus!',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFFFB84D),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '🔥 COMBO! 2x XP',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
