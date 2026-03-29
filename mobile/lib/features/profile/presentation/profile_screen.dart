import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart' as profile_model;
import 'edit_profile_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'providers/profile_providers.dart';
import '../../../providers/progress_provider.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../../splash/presentation/splash_screen.dart';
import '../../../core/utils/demo_seeder_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final contributionsAsyncValue = ref.watch(userContributionsProvider);
    final topContributorsAsync = ref.watch(topContributorsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
                onTap: () => _showLogoutConfirmation(context, ref),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Account', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _showDeleteConfirmation(context, ref),
              ),
            ],
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.red),
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
                      'No user profile exists for this account.\n\nThis could mean:\nG�� User not authenticated\nG�� User ID not found in database\nG�� Backend API error',
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
                _buildProfileHeader(profile, context, ref),
                const SizedBox(height: 24),

                // Contribution Stats
                _buildStatsSection(profile),
                const SizedBox(height: 24),

                // Gamification Progress
                _buildExplorerProgressSection(context, profile, ref),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(initialProfile: profile),
                        ),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _retryAll(WidgetRef ref) {
    ref.refresh(userProfileProvider);
    ref.refresh(userContributionsProvider);
    ref.refresh(topContributorsProvider);
    ref.refresh(progressProvider);
  }

  _ErrorUiData _buildErrorUi(Object error) {
    final message = error.toString().isEmpty
        ? 'An unexpected error occurred while loading profile data.'
        : error.toString();
    return _ErrorUiData(title: 'Error Loading Profile', message: message);
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
              child: Container(
                height: 44,
                width: double.infinity,
                color: placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(profile_model.UserProfile profile, BuildContext context, WidgetRef ref) {
    final avatarUrl = profile.avatarUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.blueGrey.shade50,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black12,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.blue.shade100,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, _, __) => Icon(
                      Icons.person_rounded,
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      size: 40,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    size: 40,
                  ),
          ),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
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
      children: badges.asMap().entries.map((entry) {
        final index = entry.key;
        final badge = entry.value;
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 260 + (index * 70)),
          tween: Tween(begin: 0.88, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBadgeColor(badge.name),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(badge.icon, style: const TextStyle(fontSize: 16)),
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplorerProgressSection(
    BuildContext context,
    profile_model.UserProfile profile,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final percentage = (profile.xpTotal % 100 / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              _showDemoSeederDialog(context, ref);
            },
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: isDark ? colorScheme.primary : Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Explorer Level ${profile.currentLevel}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${profile.xpTotal} XP',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? colorScheme.primary.withOpacity(0.8) : Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percentage,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blueGrey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.indigo),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.xpToNextLevel} XP to next level',
            style: TextStyle(color: isDark ? Colors.white38 : Colors.blueGrey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _progressChip(context, 'Achievements', profile.badges.length.toString()),
              _progressChip(context, 'Districts', '${profile.unlockedDistrictsCount}'),
              _progressChip(context, 'Provinces', '${profile.unlockedProvincesCount}'),
              _progressChip(context, 'Visits', profile.totalVisited.toString()),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isDark ? Colors.white10 : Colors.blueGrey.shade200),
                foregroundColor: isDark ? Colors.white70 : Colors.indigo,
              ),
              icon: const Icon(Icons.emoji_events_outlined, size: 18),
              label: const Text('View achievements', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressChip(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.blueGrey.shade100),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: isDark ? Colors.white38 : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContributionsSection(
    AsyncValue<List<profile_model.ContributedPlace>> asyncValue,
  ) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (places) {
        if (places.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No contributions yet. Start suggesting places!'),
          );
        }

        return Column(
          children: places
              .map(
                (place) => ListTile(
                  leading: Icon(
                    place.approved ? Icons.verified : Icons.hourglass_empty,
                    color: place.approved ? Colors.green : Colors.orange,
                  ),
                  title: Text(place.name),
                  subtitle: Text(place.approved ? 'Approved' : 'Pending'),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildLeaderboardAndImpact(profile_model.UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Global Rank: #${profile.leaderboardRank}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'Impact: ${profile.impactCount} users visited your places',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTopContributorsSection(
    AsyncValue<List<Map<String, dynamic>>> asyncValue,
  ) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Could not load leaderboard: $error'),
      data: (contributors) {
        if (contributors.isEmpty) {
          return const Text('No leaderboard data yet.');
        }

        final top = contributors.take(5).toList();
        final podium = top.take(3).toList();
        final others = top.skip(3).toList();

        return Column(
          children: [
            if (podium.isNotEmpty) _buildLeaderboardPodium(podium),
            if (others.isNotEmpty) const SizedBox(height: 8),
            ...others.asMap().entries.map((entry) {
              final rank = entry.key + 4;
              final item = entry.value;
              final name = (item['userName'] ?? 'Unknown').toString();
              final count = (item['approvedCount'] ?? 0).toString();

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blueGrey.shade100,
                  child: Text('$rank'),
                ),
                title: Text(name),
                trailing: Text('$count approved'),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardPodium(List<Map<String, dynamic>> topThree) {
    final medalColors = <Color>[
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Column(
      children: topThree.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final item = entry.value;
        final name = (item['userName'] ?? 'Unknown').toString();
        final count = (item['approvedCount'] ?? 0).toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: medalColors[entry.key].withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: medalColors[entry.key].withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: medalColors[entry.key],
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count approved',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action is PERMANENT and cannot be undone.\n\n'
          'G�� All your data will be permanently removed from our servers\n'
          'G�� Your account will be deleted from Firebase Auth\n'
          'G�� You will NOT be able to log back in with these credentials\n'
          'G�� This action happens immediately',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _performDelete(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting account permanently...'),
          duration: Duration(seconds: 2),
        ),
      );

      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not found');
      }

      // Get the current user's ID token for authentication
      final idToken = await authService.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Call the backend API to delete the account
      final repository = ref.read(profileRepositoryProvider);
      await repository.deleteAccount();

      // Sign out the user locally
      await authService.signOut();

      if (context.mounted) {
        // Show final confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account deleted successfully. You cannot log back in with these credentials.',
            ),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDemoSeederDialog(BuildContext context, WidgetRef ref) {
    final userEmail = ref.read(authServiceProvider).currentUser?.email;
    if (userEmail != 'anuja.20231258@iit.ac.lk') return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialize Hero Account?'),
        content: const Text(
          'This will reset your local progress and inject high-fidelity demo data (trips, XP, districts) into your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seeding Hero Data...')),
              );
              try {
                await ref.read(demoSeederProvider).seedHeroAccount();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hero Account Ready! Refreshing...'),
                    ),
                  );
                  _retryAll(ref);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seeding failed: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm Seed'),
          ),
        ],
      ),
    );
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
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
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
