import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/features/achievements/providers/achievements_provider.dart';
import 'package:gemified_travel_portfolio/features/places/widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(achievementsViewProvider);

    return dataAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  'Could not load achievements.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(achievementsViewProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) {
        final allAchievements = data.achievements;
        final unlocked = allAchievements.where((a) => a.isUnlocked).toList();
        final inProgress = allAchievements
            .where((a) => !a.isUnlocked && a.currentProgress > 0)
            .toList();
        final locked = allAchievements
            .where((a) => !a.isUnlocked && a.currentProgress == 0)
            .toList();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Achievements'),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Unlocked'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Locked'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(achievementsViewProvider),
                ),
              ],
            ),
            body: Column(
              children: [
                _SummaryHeader(
                  total: allAchievements.length,
                  unlocked: unlocked.length,
                  xp: data.totalXp,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AchievementGrid(items: allAchievements),
                      _AchievementGrid(items: unlocked),
                      _AchievementGrid(items: inProgress),
                      _AchievementGrid(items: locked),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int total;
  final int unlocked;
  final int xp;

  const _SummaryHeader({
    required this.total,
    required this.unlocked,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : unlocked / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '$unlocked of $total unlocked',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('$xp XP'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.amber.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'More category-based progress unlocks as visit analytics syncs.',
            style: TextStyle(color: Colors.brown.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  final List<AchievementProgress> items;

  const _AchievementGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No achievements in this section yet.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AchievementCard(achievement: items[index]);
      },
    );
  }
}
