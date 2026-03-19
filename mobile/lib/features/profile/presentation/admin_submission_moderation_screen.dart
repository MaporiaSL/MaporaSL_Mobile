import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_profile.dart';
import 'providers/profile_providers.dart';

class AdminSubmissionModerationScreen extends ConsumerWidget {
  const AdminSubmissionModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(pendingSubmissionsProvider);
    final actionState = ref.watch(moderationActionProvider);

    ref.listen(moderationActionProvider, (prev, next) {
      if (!context.mounted) return;
      if (next.success == true && prev?.success != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission reviewed successfully')),
        );
        ref.invalidate(pendingSubmissionsProvider);
        ref.invalidate(userContributionsProvider);
        ref.invalidate(userProfileProvider);
        ref.read(moderationActionProvider.notifier).clear();
      }
      if ((next.error ?? '').isNotEmpty && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Queue'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(pendingSubmissionsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load moderation queue'),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(pendingSubmissionsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No pending submissions.'));
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ModerationCard(
                item: item,
                busy: actionState.isWorking,
                onApprove: () => _review(context, ref, item, true),
                onReject: () => _review(context, ref, item, false),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    ContributedPlace item,
    bool approve,
  ) async {
    String? rejectionReason;
    if (!approve) {
      rejectionReason = await _askRejectionReason(context);
      if (rejectionReason == null || rejectionReason.trim().isEmpty) return;
    }

    await ref.read(moderationActionProvider.notifier).review(
          submissionId: item.id,
          approve: approve,
          rejectionReason: rejectionReason,
        );
  }

  Future<String?> _askRejectionReason(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Submission'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }
}

class _ModerationCard extends StatelessWidget {
  const _ModerationCard({
    required this.item,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final ContributedPlace item;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.userId != null) Chip(label: Text('User: ${item.userId}')),
                if (item.currentApprovedCount != null)
                  Chip(label: Text('Approved count: ${item.currentApprovedCount}')),
                ...item.approvalBadgePreview
                    .map((badge) => Chip(label: Text('Badge: ${badge.name}'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: busy ? null : onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
