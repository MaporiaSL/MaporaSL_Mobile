import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/user_profile.dart' as profile_model;
import 'edit_profile_screen.dart';
import 'place_submission_screen.dart';
import 'providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _retryAll(WidgetRef ref) {
    final retries = ref.read(profileRetryCountProvider.notifier);
    retries.state = retries.state + 1;
    logProfileTelemetry(
      'profile_retry_clicked',
      details: {'retryCount': retries.state},
    );
    ref.invalidate(profileBootstrapProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(userContributionsProvider);
    ref.invalidate(topContributorsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final contributionsAsyncValue = ref.watch(userContributionsProvider);
    final topContributorsAsync = ref.watch(topContributorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
      body: profileAsyncValue.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, stackTrace) {
          final errorUi = _buildErrorUi(error);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorUi.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorUi.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _retryAll(ref),
                    child: const Text('Retry'),
                  ),
                  if (errorUi.showSignInAction) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _performLogout(context, ref),
                      child: const Text('Sign In Again'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profile Not Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No user profile exists for this account.\n\nThis could mean:\n• User not authenticated\n• User ID not found in database\n• Backend API error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(userProfileProvider),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Email
                _buildProfileHeader(profile),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(profile.bio),
                ],
                if (profile.travelInterests.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.travelInterests
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),

                // Contribution Stats
                _buildStatsSection(profile),
                const SizedBox(height: 24),

                // Badges
                if (profile.badges.isNotEmpty) ...[
                  Text(
                    'Badges Earned',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildBadgesSection(profile.badges),
                  const SizedBox(height: 24),
                ],

                // Contributed Places
                Text(
                  'Contributed Places',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildContributionsSection(contributionsAsyncValue),
                const SizedBox(height: 24),

                // Leaderboard & Impact
                _buildLeaderboardAndImpact(profile),
                const SizedBox(height: 20),

                Text(
                  'Top Contributors',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _buildTopContributorsSection(topContributorsAsync),
                const SizedBox(height: 32),

                // Edit Profile Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(initialProfile: profile),
                            ),
                          );
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlaceSubmissionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Submit Place'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(profile_model.UserProfile profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: profile.avatarUrl.isNotEmpty
              ? NetworkImage(profile.avatarUrl)
              : null,
          child: profile.avatarUrl.isEmpty
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (profile.hometownDistrict.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  profile.hometownDistrict,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              if (profile.preferredLanguage.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Language: ${profile.preferredLanguage}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  _ErrorUiData _buildErrorUi(Object error) {
    if (error is ProfileLoadException) {
      switch (error.type) {
        case ProfileLoadErrorType.authLoading:
          return const _ErrorUiData(
            title: 'Preparing Your Session',
            message: 'We are still setting up your sign-in token. Please try again.',
          );
        case ProfileLoadErrorType.missingToken:
          return const _ErrorUiData(
            title: 'Sign In Required',
            message: 'Please sign in to access your profile.',
            showSignInAction: true,
          );
        case ProfileLoadErrorType.expiredToken:
          return const _ErrorUiData(
            title: 'Session Expired',
            message: 'Your login session expired. Sign in again to continue.',
            showSignInAction: true,
          );
        case ProfileLoadErrorType.userNotRegistered:
          return const _ErrorUiData(
            title: 'Creating Your Profile',
            message: 'We could not sync your account yet. Tap retry to complete setup.',
          );
        case ProfileLoadErrorType.offline:
          return const _ErrorUiData(
            title: 'No Internet Connection',
            message: 'Connect to the internet and retry loading your profile.',
          );
        case ProfileLoadErrorType.forbidden:
          return const _ErrorUiData(
            title: 'Access Denied',
            message: 'This profile request is not allowed right now. Try signing in again.',
          );
        case ProfileLoadErrorType.server:
          return const _ErrorUiData(
            title: 'Server Error',
            message: 'The server is currently unavailable. Please try again shortly.',
          );
        case ProfileLoadErrorType.unknown:
          return const _ErrorUiData(
            title: 'Unable To Load Profile',
            message: 'An unexpected error occurred. Please retry.',
          );
      }
    }

    return const _ErrorUiData(
      title: 'Error Loading Profile',
      message: 'An unexpected error occurred while loading profile data.',
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final placeholder = Colors.grey.shade300;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 40, backgroundColor: placeholder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 160, color: placeholder),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 220, color: placeholder),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (_) => Container(height: 64, width: 86, color: placeholder),
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 16, width: 170, color: placeholder),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(height: 44, width: double.infinity, color: placeholder),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(profile_model.UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard(
              label: 'Submitted',
              value: profile.totalSubmitted.toString(),
            ),
            _StatCard(
              label: 'Approved',
              value: profile.approvedCount.toString(),
            ),
            _StatCard(
              label: 'Approval Rate',
              value: '${profile.approvalRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgesSection(List<profile_model.ContributionBadge> badges) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.map((badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBadgeColor(badge.name),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                badge.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContributionsSection(
    AsyncValue<List<profile_model.ContributedPlace>> asyncValue,
  ) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Could not load submissions: $error'),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) => OutlinedButton.icon(
              onPressed: () => _retryAll(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Contributions'),
            ),
          ),
        ],
      ),
      data: (places) {
        if (places.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No submissions yet. Tap "Submit Place" to contribute your first location.'),
          );
        }

        return Column(
          children: places
              .map((place) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: place.photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              place.photoUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Icon(
                            place.approved ? Icons.verified : Icons.hourglass_empty,
                            color: place.approved ? Colors.green : Colors.orange,
                          ),
                    title: Text(place.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_statusLabel(place.status)),
                        if (place.submittedAt != null)
                          Text('Submitted: ${DateFormat.yMMMd().format(place.submittedAt!)}'),
                        if (place.status == 'rejected' && (place.rejectionReason ?? '').isNotEmpty)
                          Text('Reason: ${place.rejectionReason}'),
                      ],
                    ),
                    trailing: place.reviewedAt != null
                        ? Text(DateFormat.MMMd().format(place.reviewedAt!))
                        : null,
                  ))
              .toList(),
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Review';
    }
  }

  Widget _buildLeaderboardAndImpact(profile_model.UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Global Rank: #${profile.leaderboardRank}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Impact: ${profile.impactCount} users visited your places',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopContributorsSection(AsyncValue<List<Map<String, dynamic>>> asyncValue) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Could not load leaderboard: $error'),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) => OutlinedButton.icon(
              onPressed: () => _retryAll(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Leaderboard'),
            ),
          ),
        ],
      ),
      data: (contributors) {
        if (contributors.isEmpty) {
          return const Text('No leaderboard data yet.');
        }

        final top = contributors.take(5).toList();
        return Column(
          children: top.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final name = (item['userName'] ?? 'Unknown').toString();
            final count = (item['approvedCount'] ?? 0).toString();

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                child: Text('$rank'),
              ),
              title: Text(name),
              trailing: Text('$count approved'),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getBadgeColor(String badgeName) {
    switch (badgeName) {
      case 'Explorer':
        return Colors.blue;
      case 'Local Guide':
        return Colors.purple;
      case 'Place Curator':
        return Colors.orange;
      case 'Community Legend':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context, ref);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorUiData {
  final String title;
  final String message;
  final bool showSignInAction;

  const _ErrorUiData({
    required this.title,
    required this.message,
    this.showSignInAction = false,
  });
}
