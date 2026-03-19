import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/user_profile.dart';

class ContributionDetailScreen extends StatelessWidget {
  const ContributionDetailScreen({super.key, required this.contribution});

  final ContributedPlace contribution;

  @override
  Widget build(BuildContext context) {
    final photos = contribution.photoUrls.isNotEmpty
        ? contribution.photoUrls
        : (contribution.photoUrl.isNotEmpty
              ? [contribution.photoUrl]
              : <String>[]);

    return Scaffold(
      appBar: AppBar(title: const Text('Contribution Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            contribution.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(contribution.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusBadge(contribution.status),
              if (contribution.category.isNotEmpty)
                Chip(label: Text(contribution.category)),
              if (contribution.district.isNotEmpty)
                Chip(label: Text(contribution.district)),
              if (contribution.province.isNotEmpty)
                Chip(label: Text(contribution.province)),
            ],
          ),
          const SizedBox(height: 16),
          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final imageUrl = photos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timelineRow('Submitted', contribution.submittedAt),
                  _timelineRow('Reviewed', contribution.reviewedAt),
                  _timelineRow('Approved', contribution.approvedAt),
                  if ((contribution.rejectionReason ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Rejection reason: ${contribution.rejectionReason}',
                      ),
                    ),
                  if ((contribution.promotedPlaceId ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Promoted place id: ${contribution.promotedPlaceId}',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    final color = s == 'approved'
        ? Colors.green
        : s == 'rejected'
        ? Colors.red
        : Colors.orange;
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  Widget _timelineRow(String label, DateTime? dt) {
    final text = dt == null ? '-' : DateFormat.yMMMd().add_jm().format(dt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
