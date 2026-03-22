import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/timeline_event.dart';
import '../../../../../features/trips/data/models/trip_model.dart';
import '../../../../../features/trips/presentation/trip_detail_page.dart';

class CompletedTripCard extends StatefulWidget {
  final TimelineEvent event;
  const CompletedTripCard({super.key, required this.event});

  @override
  State<CompletedTripCard> createState() => _CompletedTripCardState();
}

class _CompletedTripCardState extends State<CompletedTripCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    final pct = widget.event.completionPercentage / 100.0;
    _progressAnimation = Tween<double>(begin: 0, end: pct).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    // Animate when card first appears
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _completionColor {
    final pct = widget.event.completionPercentage;
    if (pct >= 100) return const Color(0xFF1F8A70); // success green
    if (pct >= 75) return const Color(0xFF00A6B2);  // primary teal
    if (pct >= 50) return const Color(0xFFFFB020);  // warning gold
    return const Color(0xFF1F6F8B);                 // blue
  }

  String get _completionLabel {
    final pct = widget.event.completionPercentage;
    if (pct >= 100) return '✅ Fully Completed';
    if (pct >= 75) return '🔥 Nearly There';
    if (pct >= 50) return '⚡ Halfway Done';
    return '🗺️ In Progress';
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final pct = event.completionPercentage;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBF0), Color(0xFFFFF3D0)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: AppColors.accent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trophy icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, y').format(event.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFB020).withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'TRIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB07A00),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Description ──────────────────────────────────────
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark.withOpacity(0.8),
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 14),

              // ── Progress Bar ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _completionLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _completionColor,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _completionColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 8,
                                backgroundColor:
                                    Colors.black.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _completionColor),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Stats chips ──────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                    icon: Icons.place_rounded,
                    label:
                        '${event.visitedCount}/${event.destinationCount} spots',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.military_tech_rounded,
                    label: pct >= 100 ? 'All Cleared' : '$pct% Complete',
                    color: _completionColor,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Action button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openTripDetail(context),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text(
                    'See Trip Progress & Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTripDetail(BuildContext context) {
    final event = widget.event;

    // Build a TripModel from the timeline event data for the detail page
    final trip = TripModel(
      id: event.tripId ?? event.id,
      userId: 'local',
      title: event.title,
      description: event.description,
      startDate: event.timestamp,
      endDate: event.timestamp.add(
        Duration(days: event.destinationCount > 0 ? event.destinationCount : 3),
      ),
      locations: List.generate(
        event.destinationCount,
        (i) => TripLocation(name: 'Destination ${i + 1}', day: i + 1),
      ),
      status: 'completed',
      createdAt: event.timestamp,
      updatedAt: event.timestamp,
      completionPercentageCached: event.completionPercentage,
      destinationCount: event.destinationCount,
      visitedCount: event.visitedCount,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailPage(trip: trip),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
