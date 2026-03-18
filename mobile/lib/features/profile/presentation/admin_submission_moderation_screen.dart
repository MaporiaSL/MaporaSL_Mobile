import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/profile_providers.dart';

class AdminSubmissionModerationScreen extends ConsumerStatefulWidget {
  const AdminSubmissionModerationScreen({super.key});

  @override
  ConsumerState<AdminSubmissionModerationScreen> createState() => _AdminSubmissionModerationScreenState();
}

class _AdminSubmissionModerationScreenState extends ConsumerState<AdminSubmissionModerationScreen> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _pending = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.getPendingSubmissions();
      if (!mounted) return;
      setState(() {
        _pending = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _review(Map<String, dynamic> item, String status) async {
    String? reason;
    if (status == 'rejected') {
      reason = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Reject submission'),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Reject'),
              ),
            ],
          );
        },
      );
      if (reason == null) return;
    }

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.reviewSubmission(
        (item['id'] ?? '').toString(),
        status: status,
        rejectionReason: reason,
      );
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission ${status == 'approved' ? 'approved' : 'rejected'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderate Submissions'),
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error loading queue: $_error'))
              : _pending.isEmpty
                  ? const Center(child: Text('No pending submissions'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _pending.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _pending[index];
                        final badges = (item['approvalBadgePreview'] as List?)
                                ?.map((b) => (b as Map)['name'].toString())
                                .toList() ??
                            const [];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['placeName']?.toString() ?? 'Unnamed',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 6),
                                Text(item['description']?.toString() ?? ''),
                                const SizedBox(height: 8),
                                Text('Location: ${item['district']}, ${item['province']}'),
                                Text('Submitted by: ${item['userId'] ?? 'Unknown'}'),
                                if (badges.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: badges
                                        .map((name) => Chip(label: Text('Badge on approve: $name')))
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => _review(item, 'approved'),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Approve'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _review(item, 'rejected'),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Reject'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
