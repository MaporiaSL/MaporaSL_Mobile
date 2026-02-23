import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart' as profile_model;
import 'providers/profile_providers.dart';

/// Debug screen to diagnose profile loading issues
class ProfileDebugScreen extends ConsumerWidget {
  const ProfileDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final authService = ref.watch(authServiceProvider);
    final currentFirebaseUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Debug')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Status
            Text(
              'Authentication Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _DebugInfoCard(
              label: 'Firebase User',
              value: currentFirebaseUser?.uid ?? 'NULL (User not authenticated)',
              color: currentFirebaseUser != null ? Colors.green : Colors.red,
            ),
            _DebugInfoCard(
              label: 'Firebase Email',
              value: currentFirebaseUser?.email ?? 'N/A',
              color: Colors.blue,
            ),
            _DebugInfoCard(
              label: 'Current User ID (fromProvider)',
              value: currentUserId ?? 'NULL',
              color: currentUserId != null ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),

            // API Configuration
            Text(
              'API Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _DebugInfoCard(
              label: 'API Base URL',
              value: 'http://10.0.2.2:5000',
              color: Colors.blue,
            ),
            _DebugInfoCard(
              label: 'Profile Endpoint',
              value: 'GET /api/profile/{userId}',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Next Steps
            Text(
              'Troubleshooting',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _TroubleshootingStep(
              number: 1,
              title: 'Check Authentication',
              description: 'If "Firebase User" is NULL, user is not logged in.\nGo to login screen first.',
            ),
            _TroubleshootingStep(
              number: 2,
              title: 'Verify Backend is Running',
              description: 'Ensure Node.js server is running on port 5000.\nRun: npm start in backend/folder',
            ),
            _TroubleshootingStep(
              number: 3,
              title: 'Check Database Connection',
              description: 'Ensure MongoDB Atlas is connected.\nCheck backend logs for connection errors.',
            ),
            _TroubleshootingStep(
              number: 4,
              title: 'Verify User Record Exists',
              description: 'User must exist in MongoDB users collection with matching Firebase UID.',
            ),
            const SizedBox(height: 16),

            // Test Profile Load
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: currentUserId != null
                    ? () => ref.refresh(userProfileProvider)
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Test Profile Load'),
              ),
            ),
            const SizedBox(height: 8),

            // Back to Profile
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DebugInfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TroubleshootingStep extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _TroubleshootingStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Text(
              '$number',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
