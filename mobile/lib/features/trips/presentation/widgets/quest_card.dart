import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../exploration/data/models/exploration_models.dart';
import '../../../visits/presentation/widgets/dynamic_visit_sheet.dart';

class QuestCard extends ConsumerWidget {
  final DistrictAssignment assignment;

  const QuestCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = assignment.assignedCount > 0
        ? assignment.visitedCount / assignment.assignedCount
        : 0.0;
    final isCompleted = progress == 1.0;
    final isNew = assignment.visitedCount == 0;
    final xpReward = assignment.assignedCount * 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading: _buildLeadingIndicator(isCompleted, isNew),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  assignment.district,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              _buildXPBadge(xpReward, isCompleted),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      assignment.province,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProgressSection(context, progress),
              ],
            ),
          ),
          trailing: _buildTrailingBadge(isCompleted, isNew),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50].withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(bottom: BorderRadius.circular(20)),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  ...assignment.locations.map((loc) => _buildLocationTile(context, ref, loc)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIndicator(bool isCompleted, bool isNew) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
              : isNew
                  ? [const Color(0xFF2196F3), const Color(0xFF1976D2)]
                  : [const Color(0xFFFF9800), const Color(0xFFF57C00)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? Colors.green : isNew ? Colors.blue : Colors.orange).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        isCompleted ? Icons.emoji_events : isNew ? Icons.rocket_launch : Icons.auto_awesome,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildXPBadge(int xp, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.amber[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isCompleted ? Colors.amber[200] : Colors.blue[200])!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt,
            size: 14,
            color: isCompleted ? Colors.amber[800] : Colors.blue[800],
          ),
          const SizedBox(width: 2),
          Text(
            '+$xp XP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.amber[900] : Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quest Progress',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
                letterSpacing: 0.2,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: progress == 1.0 ? Colors.green[700] : Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingBadge(bool isCompleted, bool isNew) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green[50]
            : isNew
                ? Colors.blue[50]
                : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? 'Mastered' : isNew ? 'New Quest' : 'In Progress',
        style: TextStyle(
          color: isCompleted
              ? Colors.green[700]
              : isNew
                  ? Colors.blue[700]
                  : Colors.orange[700],
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    WidgetRef ref,
    ExplorationLocation location,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: location.visited ? Colors.green[100]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: location.visited ? Colors.green[50] : Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            location.visited ? Icons.check_circle : _getCategoryIcon(location.type),
            color: location.visited ? Colors.green : Colors.grey[400],
            size: 18,
          ),
        ),
        title: Text(
          location.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: location.visited ? FontWeight.w500 : FontWeight.w600,
            decoration: location.visited ? TextDecoration.lineThrough : null,
            color: location.visited ? Colors.grey[400] : Colors.grey[800],
          ),
        ),
        subtitle: location.type.isNotEmpty 
          ? Text(
              location.type, 
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ) 
          : null,
        trailing: !location.visited
            ? ElevatedButton(
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Offset(60, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Visit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : Icon(Icons.verified, color: Colors.green[300], size: 20),
      ),
    );
  }

  IconData _getCategoryIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('temple')) return Icons.temple_hindu;
    if (t.contains('nature') || t.contains('park')) return Icons.forest;
    if (t.contains('historical')) return Icons.account_balance;
    if (t.contains('beach')) return Icons.beach_access;
    if (t.contains('waterfall')) return Icons.water;
    return Icons.location_on_outlined;
  }
}

