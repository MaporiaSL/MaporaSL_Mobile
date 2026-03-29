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
import '../../trips/presentation/providers/trips_provider.dart';
import '../../achievements/providers/achievements_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final contributionsAsyncValue = ref.watch(userContributionsProvider);
    final progress = ref.watch(progressProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF09090B) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: profileAsyncValue.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, stackTrace) => _buildErrorUi(context, error, ref),
        data: (profile) {
          if (profile == null) return _buildProfileNotFound(context, ref);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Immersive Header
              _buildSliverAppBar(context, ref, profile),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glassmorphic Profile Card
                      _buildPremiumProfileHeader(profile, context, ref, progress.currentLevel),
                      const SizedBox(height: 32),

                      // Mission Control Grid
                      _buildMissionControlGrid(profile),
                      const SizedBox(height: 32),

                      // Legacy Progress (Contribution Insight)
                      _buildLegacyProgressSection(context, profile, ref),
                      const SizedBox(height: 32),

                      // Discovery Archive (Contributed Places)
                      _buildDiscoveryArchiveHeader(context),
                      const SizedBox(height: 16),
                      _buildDiscoveryArchive(contributionsAsyncValue),
                      const SizedBox(height: 100), // Space for bottom padding
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, profile_model.UserProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      stretch: true,
      centerTitle: false,
      title: Text(
        'Explorer Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        _buildProfileMenu(context, ref),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPremiumProfileHeader(
    profile_model.UserProfile profile,
    BuildContext context,
    WidgetRef ref,
    int? localLevel,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = (localLevel ?? 0) > profile.currentLevel ? localLevel! : profile.currentLevel;
    final rankColor = _getRankColor(level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Rank Aura
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing Aura
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      rankColor.withValues(alpha: 0.0),
                      rankColor.withValues(alpha: 0.5),
                      rankColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Inner Border
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor.withValues(alpha: 0.3), width: 2),
                ),
              ),
              // Avatar
              CircleAvatar(
                radius: 42,
                backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                backgroundImage: profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) : null,
                child: profile.avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 40, color: isDark ? Colors.white24 : Colors.grey.shade400)
                    : null,
              ),
              // Rank Badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'LVL $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildEditProfileButton(context, profile),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, profile_model.UserProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditProfileScreen(initialProfile: profile)),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'Modify Identity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int level) {
    if (level >= 50) return const Color(0xFFFFD700); // Gold
    if (level >= 30) return const Color(0xFFFFA000); // Amber
    if (level >= 15) return const Color(0xFFA855F7); // Purple
    return const Color(0xFF3B82F6); // Blue
  }

  Widget _buildErrorUi(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'TELEMETRY LOST',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().isEmpty ? 'An unexpected error occurred while loading profile data.' : error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _retryAll(ref),
              child: const Text('RE-ESTABLISH CONNECTION'),
            ),
          ],
        ),
      ),
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

  Widget _buildMissionControlGrid(profile_model.UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Mission Control', subtitle: 'Real-time Explorer Telemetry'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16, crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _DataBlock(
              label: 'DISTRICTS UNLOCKED',
              value: '${profile.unlockedDistrictsCount}',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF3B82F6),
              suffix: '/ 25',
            ),
            _DataBlock(
              label: 'PROVINCES EXPLORED',
              value: '${profile.unlockedProvincesCount}',
              icon: Icons.map_rounded,
              color: const Color(0xFFF59E0B),
              suffix: '/ 9',
            ),
            _DataBlock(
              label: 'MISSIONS ASSIGNED',
              value: profile.totalAssigned.toString(),
              icon: Icons.assignment_rounded,
              color: const Color(0xFFA855F7),
            ),
            _DataBlock(
              label: 'MISSIONS COMPLETED',
              value: profile.totalVisited.toString(),
              icon: Icons.verified_rounded,
              color: const Color(0xFF10B981),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegacyProgressSection(
    BuildContext context,
    profile_model.UserProfile profile,
    WidgetRef ref,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(progressProvider);
    final displayXP = progress.totalXP > profile.xpTotal ? progress.totalXP : profile.xpTotal;
    final percentage = (displayXP % 100 / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Legacy Progress', subtitle: 'Evolution of your journey'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP SYNCHRONIZATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${profile.xpToNextLevel} XP REQUIRED FOR NEXT EVOLUTION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white24 : Colors.black26,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              Row(
                children: [
                  _LegacyStat(label: 'DATA LOGS', value: profile.totalSubmitted.toString()),
                  const SizedBox(width: 32),
                  _LegacyStat(label: 'PRECISION RATE', value: '${profile.approvalRate.toStringAsFixed(1)}%'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryArchiveHeader(BuildContext context) {
    return const _SectionHeader(title: 'Discovery Archive', subtitle: 'Your contributions to the monolith');
  }

  Widget _buildDiscoveryArchive(AsyncValue<List<profile_model.ContributedPlace>> asyncValue) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (places) {
        if (places.isEmpty) {
          return const _EmptyArchive();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return _DiscoveryTile(place: place);
          },
        );
      },
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

  void _retryAll(WidgetRef ref) {
    ref.invalidate(userProfileProvider);
    ref.invalidate(userContributionsProvider);
    ref.invalidate(topContributorsProvider);
    ref.invalidate(progressProvider);
    ref.invalidate(tripsProvider);
    ref.invalidate(achievementsViewProvider);
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text('Logout Connection'),
            ],
          ),
          onTap: () => Future.delayed(Duration.zero, () => _showLogoutConfirmation(context, ref)),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete_forever, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Terminate Account', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => Future.delayed(Duration.zero, () => _showDeleteConfirmation(context, ref)),
        ),
      ],
    );
  }

  Widget _buildProfileNotFound(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          const Text('IDENTITY NOT FOUND'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => ref.refresh(userProfileProvider),
            child: const Text('SEARCH AGAIN'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Explorer?'),
        content: const Text('Your current session telemetry will be archived and you will be returned to the launch pad.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(onPressed: () => _performLogout(context, ref), child: const Text('DISCONNECT', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TERMINATE IDENTITY?'),
        content: const Text('WARNING: This action is permanent. All discovery logs and telemetry will be purged from the monolith.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(onPressed: () => _performDelete(context, ref), child: const Text('TERMINATE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _performDelete(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.deleteAccount();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Termination Failed: $e')));
      }
    }
  }

}

class _ErrorUiData {
  final String title;
  final String message;
  _ErrorUiData({required this.title, required this.message});
}

// Premium UI Components
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DataBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? suffix;

  const _DataBlock({required this.label, required this.value, required this.icon, required this.color, this.suffix});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.05) : color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    suffix!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegacyStat extends StatelessWidget {
  final String label;
  final String value;

  const _LegacyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DiscoveryTile extends StatelessWidget {
  final profile_model.ContributedPlace place;

  const _DiscoveryTile({required this.place});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (place.approved ? Colors.green : Colors.orange).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              place.approved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
              size: 20,
              color: place.approved ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  place.approved ? 'AUTHENTICATED DISCOVERY' : 'PENDING VERIFICATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white12 : Colors.black12),
        ],
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 40, color: Colors.white12),
          SizedBox(height: 16),
          Text(
            'NO DISCOVERY LOGS FOUND',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
