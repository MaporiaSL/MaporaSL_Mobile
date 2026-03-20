import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;

/// XP Multiplier System with Combo tracking and environmental bonuses
/// Features:
/// - Same-day combo (3+ places = 2x XP)
/// - Weather/Time bonuses (sunrise, poya days, seasonal)
/// - Streak multiplier (consecutive days)

class XPMultiplierNotifier extends StateNotifier<XPMultiplierState> {
  XPMultiplierNotifier() : super(const XPMultiplierState());

  /// Record an unlock and calculate XP with multipliers
  Future<void> recordUnlock({
    required String districtName,
    required String tier, // sameDistrict, sameProvince, otherProvince
    required double latitude,
    required double longitude,
    required DateTime unlockTime,
  }) async {
    final baseXp = _getBaseXp(tier);

    // Calculate today's unlocks for same-day combo
    final today = DateTime(unlockTime.year, unlockTime.month, unlockTime.day);
    final todayUnlocks = state.unlockedToday
        .where(
          (unlock) =>
              DateTime(
                unlock.unlockedAt.year,
                unlock.unlockedAt.month,
                unlock.unlockedAt.day,
              ) ==
              today,
        )
        .length;

    // Apply same-day combo multiplier
    var comboMultiplier = 1.0;
    if (todayUnlocks >= 2) {
      // 3rd+ unlock in a day gets 2x multiplier
      comboMultiplier = 2.0;
    } else if (todayUnlocks == 1) {
      // 2nd unlock gets 1.5x
      comboMultiplier = 1.5;
    }

    // Get environmental bonuses
    final environmentalBonus = await _getEnvironmentalBonuses(
      latitude: latitude,
      longitude: longitude,
      unlockTime: unlockTime,
    );

    // Calculate streak bonus (consecutive days)
    final streakBonus = _calculateStreakBonus();

    // Final XP calculation
    var finalXp = (baseXp * comboMultiplier) + environmentalBonus + streakBonus;

    // Add random bonus (0-4)
    finalXp += math.Random().nextDouble() * 4.0;

    // Record unlock
    final unlock = XPUnlock(
      districtName: districtName,
      baseXp: baseXp,
      comboMultiplier: comboMultiplier,
      environmentalBonus: environmentalBonus,
      streakBonus: streakBonus,
      finalXp: finalXp,
      unlockedAt: unlockTime,
      tier: tier,
    );

    // Update state
    state = state.copyWith(
      unlockedToday: [...state.unlockedToday, unlock],
      totalXpThisSession: state.totalXpThisSession + finalXp,
      currentComboCount: todayUnlocks + 1,
      lastUnlockTime: unlockTime,
    );

    // Check if streak should be updated (if unlock is on a new day)
    _updateStreak(unlockTime);
  }

  /// Get base XP for tier
  int _getBaseXp(String tier) {
    return switch (tier) {
      'sameDistrict' => 10,
      'sameProvince' => 12,
      'otherProvince' => 15,
      _ => 10,
    };
  }

  /// Calculate environmental bonuses (sunrise, poya days, weather, etc.)
  Future<double> _getEnvironmentalBonuses({
    required double latitude,
    required double longitude,
    required DateTime unlockTime,
  }) async {
    double bonus = 0;

    // Sunrise bonus (6 AM - 7 AM)
    if (unlockTime.hour == 6) {
      bonus += 5; // Golden Hour XP
    }

    // Sunset bonus (5 PM - 6 PM)
    if (unlockTime.hour == 17) {
      bonus += 4; // Sunset bonus
    }

    // Poya day bonus (Buddhist holidays)
    if (_isPoyaDay(unlockTime)) {
      bonus += 10; // Cultural celebration bonus
    }

    // Weekend exploration bonus (+2x multiplier on weekends)
    if (unlockTime.weekday == DateTime.saturday ||
        unlockTime.weekday == DateTime.sunday) {
      bonus += 3; // Weekend wanderer bonus
    }

    // Weather-based bonus (currently simulated, would integrate real API)
    if (_isLikelyRainy(unlockTime)) {
      bonus += 2; // Brave explorer bonus
    }

    return bonus;
  }

  /// Check if day is a Poya day (Buddhist holiday in Sri Lanka)
  bool _isPoyaDay(DateTime date) {
    // Simplified - actual implementation would use lunar calendar
    // Main Poya days in Sri Lanka:
    // - Wesak (April-May): 12th-13th
    // - Poson (June): 15th-16th
    // - Esala (July-August): 26th-27th
    // - Il (October-November): 12th-13th
    // - Unduwap (December): 12th-13th

    final month = date.month;
    final day = date.day;

    return (month == 4 && (day == 12 || day == 13)) || // Wesak
        (month == 5 && (day == 12 || day == 13)) || // Wesak late
        (month == 6 && (day == 15 || day == 16)) || // Poson
        (month == 7 && (day == 26 || day == 27)) || // Esala
        (month == 8 && (day == 26 || day == 27)) || // Esala late
        (month == 10 && (day == 12 || day == 13)) || // Il
        (month == 11 && (day == 12 || day == 13)) || // Il late
        (month == 12 && (day == 12 || day == 13)); // Unduwap
  }

  /// Simulate weather likelihood (would integrate real weather API)
  bool _isLikelyRainy(DateTime date) {
    // Sri Lanka rainy seasons:
    // - SW monsoon: May-August (higher chance)
    // - NE monsoon: December-February
    final month = date.month;
    const swMonsoonMonths = [5, 6, 7, 8];
    const neMonsoonMonths = [12, 1, 2];

    return swMonsoonMonths.contains(month) ||
        neMonsoonMonths.contains(month) ||
        (math.Random().nextDouble() < 0.2); // 20% chance otherwise
  }

  /// Calculate consecutive days bonus
  double _calculateStreakBonus() {
    if (state.streakDays == 0) return 0;

    // 1 day = 0, 2 days = 1 XP, 3 days = 2 XP, 4 days = 3 XP, etc.
    return (state.streakDays - 1).toDouble();
  }

  /// Update streak on new day
  void _updateStreak(DateTime unlockTime) {
    if (state.lastUnlockTime == null) {
      state = state.copyWith(streakDays: 1, streakStartDate: unlockTime);
      return;
    }

    final lastDate = DateTime(
      state.lastUnlockTime!.year,
      state.lastUnlockTime!.month,
      state.lastUnlockTime!.day,
    );
    final currentDate = DateTime(
      unlockTime.year,
      unlockTime.month,
      unlockTime.day,
    );

    final daysDiff = currentDate.difference(lastDate).inDays;

    if (daysDiff == 1) {
      // Consecutive day - extend streak
      state = state.copyWith(streakDays: state.streakDays + 1);
    } else if (daysDiff == 0) {
      // Same day - no change
    } else {
      // Streak broken - reset
      state = state.copyWith(
        streakDays: 1,
        streakStartDate: unlockTime,
        streakBrokenCount: state.streakBrokenCount + 1,
      );
    }
  }

  /// Reset daily combo counter (call at midnight)
  void resetDailyCombo() {
    state = state.copyWith(unlockedToday: [], currentComboCount: 0);
  }

  /// Reset entire session (when app closes)
  void resetSession() {
    state = const XPMultiplierState();
  }
}

class XPUnlock {
  final String districtName;
  final int baseXp;
  final double comboMultiplier;
  final double environmentalBonus;
  final double streakBonus;
  final double finalXp;
  final DateTime unlockedAt;
  final String tier;

  XPUnlock({
    required this.districtName,
    required this.baseXp,
    required this.comboMultiplier,
    required this.environmentalBonus,
    required this.streakBonus,
    required this.finalXp,
    required this.unlockedAt,
    required this.tier,
  });

  String get bonusBreakdown {
    return 'Base: $baseXp | Combo: ×${comboMultiplier.toStringAsFixed(1)} | Env: +${environmentalBonus.toStringAsFixed(1)} | Streak: +${streakBonus.toStringAsFixed(1)}';
  }
}

class XPMultiplierState {
  final List<XPUnlock> unlockedToday;
  final double totalXpThisSession;
  final int currentComboCount; // 1, 2, 3+
  final int streakDays;
  final DateTime? streakStartDate;
  final int streakBrokenCount;
  final DateTime? lastUnlockTime;

  const XPMultiplierState({
    this.unlockedToday = const [],
    this.totalXpThisSession = 0,
    this.currentComboCount = 0,
    this.streakDays = 0,
    this.streakStartDate,
    this.streakBrokenCount = 0,
    this.lastUnlockTime,
  });

  XPMultiplierState copyWith({
    List<XPUnlock>? unlockedToday,
    double? totalXpThisSession,
    int? currentComboCount,
    int? streakDays,
    DateTime? streakStartDate,
    int? streakBrokenCount,
    DateTime? lastUnlockTime,
  }) {
    return XPMultiplierState(
      unlockedToday: unlockedToday ?? this.unlockedToday,
      totalXpThisSession: totalXpThisSession ?? this.totalXpThisSession,
      currentComboCount: currentComboCount ?? this.currentComboCount,
      streakDays: streakDays ?? this.streakDays,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      streakBrokenCount: streakBrokenCount ?? this.streakBrokenCount,
      lastUnlockTime: lastUnlockTime ?? this.lastUnlockTime,
    );
  }

  /// Get combo emoji/status
  String get comboStatus {
    return switch (currentComboCount) {
      0 => '',
      1 => '1/3 to combo 🔥',
      2 => '2/3 to combo! 🔥🔥',
      >= 3 => '🔥 COMBO! 2x XP! 🔥',
      _ => '',
    };
  }

  /// Get streak display
  String get streakDisplay => streakDays == 0
      ? 'Start your streak!'
      : '🔥 $streakDays day streak (Bonus: +${(streakDays - 1).toDouble().toStringAsFixed(1)} XP)';
}

/// XP Multiplier provider
final xpMultiplierProvider =
    StateNotifierProvider<XPMultiplierNotifier, XPMultiplierState>((ref) {
      return XPMultiplierNotifier();
    });
