import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exploration/data/models/exploration_models.dart';
import '../../exploration/providers/exploration_provider.dart';

class QuestCard extends ConsumerWidget {
  final DistrictAssignment assignment;

  const QuestCard({
    super.key,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = assignment.assignedCount > 0
        ? assignment.visitedCount / assignment.assignedCount
        : 0.0;
    final isUnlocked = assignment.unlockedAt != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: _buildLeadingIcon(isUnlocked),
        title: Text(
          assignment.district,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.province, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _buildProgressBar(context, progress),
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.verified, color: Colors.green)
            : Text('${assignment.visitedCount}/${assignment.assignedCount}'),
        children: assignment.locations.map((loc) => _buildLocationTile(context, ref, loc)).toList(),
      ),
    );
  }

  Widget _buildLeadingIcon(bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUnlocked ? Icons.stars : Icons.explore_outlined,
        color: isUnlocked ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLocationTile(BuildContext context, WidgetRef ref, ExplorationLocation location) {
    return ListTile(
      dense: true,
      leading: Icon(
        location.visited ? Icons.check_circle : Icons.location_on_outlined,
        color: location.visited ? Colors.green : Colors.grey,
        size: 20,
      ),
      title: Text(
        location.name,
        style: TextStyle(
          decoration: location.visited ? TextDecoration.lineThrough : null,
          color: location.visited ? Colors.grey : null,
        ),
      ),
      subtitle: location.type.isNotEmpty ? Text(location.type) : null,
      trailing: !location.visited
          ? TextButton(
              onPressed: () {
                ref.read(explorationProvider.notifier).verifyLocation(location);
              },
              child: const Text('Visit'),
            )
          : null,
    );
  }
}
