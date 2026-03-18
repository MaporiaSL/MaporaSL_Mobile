import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/user_profile.dart';

class ContributionDetailScreen extends StatelessWidget {
  const ContributionDetailScreen({super.key, required this.contribution});

  final ContributedPlace contribution;

  @override
  Widget build(BuildContext context) {
    final dates = <MapEntry<String, DateTime?>>[
      MapEntry('Submitted', contribution.submittedAt),
      MapEntry('Reviewed', contribution.reviewedAt),
      MapEntry('Approved', contribution.approvedAt),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(contribution.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (contribution.photoUrls.isNotEmpty)
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: contribution.photoUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = contribution.photoUrls[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 36),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          Text(
            _statusTitle(contribution.status),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(contribution.description),
          if ((contribution.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text('Rejection reason: ${contribution.rejectionReason}'),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Status timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...dates.map((entry) {
            final value = entry.value;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                value == null ? Icons.radio_button_unchecked : Icons.check_circle,
                color: value == null ? Colors.grey : Colors.green,
              ),
              title: Text(entry.key),
              subtitle: Text(value == null ? 'Not available' : DateFormat.yMMMd().add_jm().format(value)),
            );
          }),
        ],
      ),
    );
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'approved':
        return 'Approved Contribution';
      case 'rejected':
        return 'Rejected Contribution';
      default:
        return 'Pending Contribution';
    }
  }
}
