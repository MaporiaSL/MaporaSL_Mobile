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
          leading: _buildLeadingIndicator(assignment.isUnlocked, isCompleted),
          title: Text(
            assignment.district,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.province,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProgressSection(context, progress),
              ],
            ),
          ),
          trailing: _buildTrailingBadge(
            isCompleted, 
            isNew, 
            assignment.isUnlocked,
            assignment.visitedCount,
            assignment.assignedCount,
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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

  Widget _buildProgressSection(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quest Progress',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
            letterSpacing: 0.2,
          ),
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

  Widget _buildLeadingIndicator(bool isUnlocked, bool isCompleted) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isUnlocked 
            ? (isCompleted ? Colors.green[50] : Colors.blue[50]) 
            : Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUnlocked 
            ? (isCompleted ? Icons.verified : Icons.explore) 
            : Icons.lock,
        color: isUnlocked 
            ? (isCompleted ? Colors.green[600] : Colors.blue[600]) 
            : Colors.grey[600],
        size: 22,
      ),
    );
  }

  Widget _buildTrailingBadge(bool isCompleted, bool isNew, bool isUnlocked, int visited, int total) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Mastered',
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$visited/$total',
          style: TextStyle(
            color: Colors.blue[400],
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (!isUnlocked)
          const Text(
            'Locked',
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
      ],
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
        trailing: location.visited
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unlocked',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                    child: Icon(Icons.check, color: Colors.green[400], size: 12),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Locked',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
      ),
    );
  }
}

