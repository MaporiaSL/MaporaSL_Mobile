import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/preplanned_trip_model.dart';
import 'providers/preplanned_trips_provider.dart';
import 'providers/trips_provider.dart';
import 'memory_lane_page.dart';
import 'create_trip_page.dart';
import 'widgets/explorer_stats_card.dart';
import 'widgets/trips_debug_panel.dart';

/// Trip Planning Hub - plan custom trips or start curated adventures, plus view explorer stats.
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

/// Legacy entry point retained for existing navigation usages.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) => const TripsScreen();
}

class _TripsScreenState extends ConsumerState<TripsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _planningScroll = ScrollController();
  final _statsScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(() => setState(() {}));

    // Load trips on init
    Future.microtask(() => ref.read(tripsProvider.notifier).loadTrips());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _planningScroll.dispose();
    _statsScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(preplannedTripsFutureProvider);
    final filters = ref.watch(preplannedFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'Memory Lane',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryLanePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Dev Tools',
            onPressed: () => showTripsDebugPanel(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Plan Journey'),
            Tab(text: 'Explorer Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(preplannedTripsFutureProvider);
              await ref.read(preplannedTripsFutureProvider.future);
            },
            child: _buildTripPlanningTab(templatesAsync, filters),
          ),
          RefreshIndicator(
            onRefresh: () async {},
            child: _buildExplorerStatsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTripPlanningTab(
    AsyncValue<List<PrePlannedTripModel>> templatesAsync,
    PreplannedFilters filters,
  ) {
    return ListView(
      controller: _planningScroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _showCreateCustomTripForm,
            icon: const Icon(Icons.add),
            label: const Text('Create Custom Trip'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR DISCOVER PRE-PLANNED QUESTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _DiscoverFilters(
          filters: filters,
          onChanged: (updated) =>
              ref.read(preplannedFiltersProvider.notifier).state = updated,
          onClear: () => ref.read(preplannedFiltersProvider.notifier).state =
              const PreplannedFilters(),
        ),
        const SizedBox(height: 12),
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No curated adventures found.'),
                ),
              );
            }
            return Column(
              children: templates
                  .map(
                    (tpl) => _TemplateCard(
                      template: tpl,
                      onStart: () => _startAdventure(tpl),
                      onPreview: () => _showTemplatePreview(tpl),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(err.toString()),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(preplannedTripsFutureProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplorerStatsTab() {
    return ListView(
      controller: _statsScroll,
      padding: const EdgeInsets.all(16),
      children: [
        const ExplorerStatsCard(),
        const SizedBox(height: 24),
        Text(
          'Your Achievements',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AchievementItem(
                  icon: '🏔️',
                  title: 'Mountain Explorer',
                  description: 'Visited 5 mountain destinations',
                ),
                SizedBox(height: 12),
                _AchievementItem(
                  icon: '🏖️',
                  title: 'Beach Master',
                  description: 'Completed 3 coastal trips',
                ),
                SizedBox(height: 12),
                _AchievementItem(
                  icon: '🏛️',
                  title: 'History Buff',
                  description: 'Visited 10 historical sites',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateCustomTripForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTripPage()),
    );
  }

  Future<void> _startAdventure(PrePlannedTripModel template) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Choose your adventure dates',
    );

    if (range == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(
        startAdventureProvider(
          StartAdventureRequest(
            templateId: template.id,
            startDate: range.start,
            endDate: range.end,
          ),
        ).future,
      );
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Added to My Journeys: ${template.title}')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to start adventure: $e')),
      );
    }
  }

  void _showTemplatePreview(PrePlannedTripModel template) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              template.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(template.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('${template.durationDays} days')),
                Chip(label: Text('${template.xpReward} XP')),
                Chip(label: Text(template.difficulty)),
                ...template.tags.map((tag) => Chip(label: Text(tag))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Stops (${template.placeIds.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...template.placeIds.map(
              (p) => ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(p),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startAdventure(template);
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Start Adventure'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverFilters extends StatelessWidget {
  final PreplannedFilters filters;
  final ValueChanged<PreplannedFilters> onChanged;
  final VoidCallback onClear;

  const _DiscoverFilters({
    required this.filters,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(onPressed: onClear, child: const Text('Clear All')),
          ],
        ),
        const SizedBox(height: 12),
        // Single row with dropdowns
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterDropdown(
                label: 'Duration',
                value: filters.duration,
                options: const ['1-3', '4-6', '7+'],
                onChanged: (val) => onChanged(filters.copyWith(duration: val)),
              ),
              const SizedBox(width: 12),
              _FilterDropdown(
                label: 'Difficulty',
                value: filters.difficulty,
                options: const ['Easy', 'Moderate', 'Hard'],
                onChanged: (val) =>
                    onChanged(filters.copyWith(difficulty: val)),
              ),
              const SizedBox(width: 12),
              _FilterDropdown(
                label: 'Starting Point',
                value: filters.startingPoint,
                options: const [
                  'Colombo',
                  'Kandy',
                  'Galle',
                  'Jaffna',
                  'Trinco',
                ],
                onChanged: (val) =>
                    onChanged(filters.copyWith(startingPoint: val)),
              ),
              const SizedBox(width: 12),
              _ThemeMultiSelect(
                selected: filters.tags,
                onChanged: (tags) => onChanged(filters.copyWith(tags: tags)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      hint: Text(label),
      value: value,
      underline: Container(height: 2, color: Colors.blue),
      items: [
        DropdownMenuItem(value: null, child: Text('$label (Any)')),
        ...options.map((opt) {
          return DropdownMenuItem(value: opt, child: Text(opt));
        }),
      ],
      onChanged: onChanged,
    );
  }
}

class _ThemeMultiSelect extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _ThemeMultiSelect({required this.selected, required this.onChanged});

  @override
  State<_ThemeMultiSelect> createState() => _ThemeMultiSelectState();
}

class _ThemeMultiSelectState extends State<_ThemeMultiSelect> {
  final _themes = const [
    'Beach',
    'Mountain',
    'Culture',
    'Nature',
    'City',
    'History',
    'Adventure',
    'Relaxation',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 2),
        ),
      ),
      child: DropdownButton<String>(
        hint: const Text('Themes'),
        underline: const SizedBox(),
        items: _themes.map((theme) {
          final isSelected = widget.selected.contains(theme);
          return DropdownMenuItem(
            value: theme,
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleTheme(theme),
                ),
                Text(theme),
              ],
            ),
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }

  void _toggleTheme(String theme) {
    final updated = List<String>.from(widget.selected);
    if (updated.contains(theme)) {
      updated.remove(theme);
    } else {
      updated.add(theme);
    }
    widget.onChanged(updated);
  }
}

class _FilterCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _FilterCategory({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final List<String>? selectedList;
  final bool multiSelect;
  final ValueChanged<String?>? onSelect;
  final ValueChanged<List<String>>? onSelectList;

  const _FilterSection({
    required this.title,
    required this.options,
    this.selected,
    this.selectedList,
    this.multiSelect = false,
    this.onSelect,
    this.onSelectList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            if (multiSelect) {
              final current = selectedList ?? [];
              final isSelected = current.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (_) {
                  final next = List<String>.from(current);
                  if (isSelected) {
                    next.remove(opt);
                  } else {
                    next.add(opt);
                  }
                  onSelectList?.call(next);
                },
              );
            }
            return ChoiceChip(
              label: Text(opt),
              selected: selected == opt,
              onSelected: (_) => onSelect?.call(selected == opt ? null : opt),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PrePlannedTripModel template;
  final VoidCallback onPreview;
  final VoidCallback onStart;

  const _TemplateCard({
    required this.template,
    required this.onPreview,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              template.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text('${template.durationDays} days')),
                Chip(label: Text('${template.xpReward} XP')),
                Chip(label: Text(template.difficulty)),
                if (template.tags.isNotEmpty)
                  Chip(label: Text(template.tags.take(2).join(', '))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Preview'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Start Adventure'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
