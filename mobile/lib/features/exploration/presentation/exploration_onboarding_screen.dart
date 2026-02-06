import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/districts_data.dart';
import '../providers/exploration_provider.dart';
import '../../../core/services/auth_api.dart';

class ExplorationOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const ExplorationOnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  ConsumerState<ExplorationOnboardingScreen> createState() =>
      _ExplorationOnboardingScreenState();
}

class _ExplorationOnboardingScreenState
    extends ConsumerState<ExplorationOnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedDistrict;
  bool _isSubmitting = false;
  bool _showSummary = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_selectedDistrict == null ||
        _nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter name, email, and hometown district.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AuthApi().registerUser(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        hometownDistrict: _selectedDistrict!,
      );
      await ref.read(explorationProvider.notifier).loadAssignments();
      setState(() {
        _showSummary = true;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary) {
      return _ExplorationSummaryView(onCompleted: widget.onCompleted);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Exploration Map')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your hometown district to personalize your map.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              items: sriLankaDistricts
                  .map(
                    (district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDistrict = value),
              decoration: const InputDecoration(labelText: 'Hometown District'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _register,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Exploration Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplorationSummaryView extends ConsumerWidget {
  final VoidCallback onCompleted;

  const _ExplorationSummaryView({required this.onCompleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationProvider);
    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalLocations = state.assignments.fold<int>(
      0,
      (sum, assignment) => sum + assignment.assignedCount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your Exploration Map')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map created! Here is a quick summary:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _SummaryTile(
              label: 'Districts assigned',
              value: state.assignments.length.toString(),
            ),
            const SizedBox(height: 8),
            _SummaryTile(
              label: 'Total locations',
              value: totalLocations.toString(),
            ),
            if (state.assignments.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'No assignments found yet. Try refreshing later.',
                  style: TextStyle(color: Colors.redAccent.shade200),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _ExplorationDetailsView(),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCompleted,
                child: const Text('Continue to Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplorationDetailsView extends ConsumerWidget {
  const _ExplorationDetailsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationProvider);
    final provinces = state.assignments
        .map((assignment) => assignment.province)
        .toSet()
        .toList()
      ..sort();

    final tabs = ['All', ...provinces];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exploration Details'),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            final filtered = tab == 'All'
                ? state.assignments
                : state.assignments
                    .where((assignment) => assignment.province == tab)
                    .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final assignment = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(assignment.district),
                    subtitle: Text(
                      '${assignment.visitedCount}/${assignment.assignedCount} visited',
                    ),
                    children: assignment.locations
                        .map(
                          (location) => ListTile(
                            title: Text(location.name),
                            subtitle: Text(location.type),
                            trailing: Icon(
                              location.visited
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: location.visited
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
