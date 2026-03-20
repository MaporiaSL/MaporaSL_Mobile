import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/profile_setup_localizations.dart';
import '../domain/user_profile.dart' as profile_model;
import 'admin_submission_moderation_screen.dart';
import 'contribution_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'place_submission_screen.dart';
import 'providers/profile_providers.dart';
import 'resubmit_contribution_screen.dart';

enum _ContributionFilter { all, pending, approved, rejected }

enum _ContributionSort { newest, oldest, status }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  _ContributionFilter _filter = _ContributionFilter.all;
  _ContributionSort _sort = _ContributionSort.newest;

  ProfileSetupLocalizations get _l10n => ProfileSetupLocalizations.of(context);

  void _retryAll() {
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
    ref.invalidate(pendingSubmissionsProvider);
  }

  void _refreshContributionViews() {
    ref.invalidate(userContributionsProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(pendingSubmissionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final contributionsAsyncValue = ref.watch(userContributionsProvider);
    final topContributorsAsync = ref.watch(topContributorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.myProfile),
        actions: [
          if (AppConfig.authBypass)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: _l10n.moderationQueue,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSubmissionModerationScreen(),
                  ),
                );
                if (!mounted) return;
                _refreshContributionViews();
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: _l10n.logout,
            onPressed: _showLogoutConfirmation,
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
                    onPressed: _retryAll,
                    child: Text(_l10n.retry),
                  ),
                  if (errorUi.showSignInAction) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _performLogout,
                      child: Text(_l10n.signInAgain),
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
                      _l10n.profileNotFound,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _l10n.profileNotFoundBody,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryAll,
                      child: Text(_l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _retryAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _buildStatsSection(profile),
                  const SizedBox(height: 24),
                  if (profile.badges.isNotEmpty) ...[
                    Text(
                      _l10n.badgesEarned,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildBadgesSection(profile.badges),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    _l10n.contributedPlaces,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildContributionControls(),
                  const SizedBox(height: 8),
                  _buildContributionsSection(contributionsAsyncValue),
                  const SizedBox(height: 24),
                  _buildLeaderboardAndImpact(profile),
                  const SizedBox(height: 20),
                  Text(
                    _l10n.topContributors,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _buildTopContributorsSection(topContributorsAsync),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
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
                          child: Text(_l10n.editProfile),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlaceSubmissionScreen(),
                              ),
                            );
                            if (!mounted) return;
                            _refreshContributionViews();
                          },
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text(_l10n.submitPlace),
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

  Widget _buildContributionControls() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(_l10n.all, _ContributionFilter.all),
                const SizedBox(width: 8),
                _filterChip(_l10n.pending, _ContributionFilter.pending),
                const SizedBox(width: 8),
                _filterChip(_l10n.approved, _ContributionFilter.approved),
                const SizedBox(width: 8),
                _filterChip(_l10n.rejected, _ContributionFilter.rejected),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<_ContributionSort>(
          value: _sort,
          items: [
            DropdownMenuItem(
              value: _ContributionSort.newest,
              child: Text(_l10n.newest),
            ),
            DropdownMenuItem(
              value: _ContributionSort.oldest,
              child: Text(_l10n.oldest),
            ),
            DropdownMenuItem(
              value: _ContributionSort.status,
              child: Text(_l10n.status),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sort = value);
          },
        ),
      ],
    );
  }

  Widget _filterChip(String label, _ContributionFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildProfileHeader(profile_model.UserProfile profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: profile.avatarUrl.isNotEmpty
              ? NetworkImage(_cacheBustedAvatar(profile.avatarUrl))
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (profile.hometownDistrict.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  profile.hometownDistrict,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
              if (profile.preferredLanguage.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '${_l10n.languagePrefix} ${profile.preferredLanguage}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
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
              label: _l10n.submitted,
              value: profile.totalSubmitted.toString(),
            ),
            _StatCard(
              label: _l10n.approved,
              value: profile.approvedCount.toString(),
            ),
            _StatCard(
              label: _l10n.approvalRate,
              value: '${profile.approvalRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard(
              label: _l10n.districtsUnlocked,
              value: profile.unlockedDistrictsCount.toString(),
            ),
            _StatCard(
              label: _l10n.provincesUnlocked,
              value: profile.unlockedProvincesCount.toString(),
            ),
            _StatCard(
              label: _l10n.placesVisited,
              value: profile.totalPlacesVisited.toString(),
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
          Text(_l10n.contributionsLoadError),
          const SizedBox(height: 4),
          Text(
            _buildErrorUi(error).message,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _retryAll,
            icon: const Icon(Icons.refresh),
            label: Text(_l10n.retryContributions),
          ),
        ],
      ),
      data: (places) {
        final filtered = _filterAndSort(places);
        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_l10n.noSubmissionsInView),
          );
        }

        return Column(
          children: filtered
              .map(
                (place) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: place.photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              place.photoUrl,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Icon(
                            Icons.place_outlined,
                            color: _statusColor(place.status),
                          ),
                    title: Text(place.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(place.status),
                          style: TextStyle(color: _statusColor(place.status)),
                        ),
                        if (place.submittedAt != null)
                          Text(
                            '${_l10n.submittedPrefix} ${DateFormat.yMMMd().format(place.submittedAt!)}',
                          ),
                        if (place.status == 'rejected' &&
                            (place.rejectionReason ?? '').isNotEmpty)
                          Text(
                            '${_l10n.reasonPrefix} ${place.rejectionReason}',
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: _l10n.viewDetails,
                      onPressed: () => _openContributionDetail(place),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  List<profile_model.ContributedPlace> _filterAndSort(
    List<profile_model.ContributedPlace> items,
  ) {
    var result = items.where((item) {
      if (_filter == _ContributionFilter.all) return true;
      if (_filter == _ContributionFilter.pending)
        return item.status == 'pending';
      if (_filter == _ContributionFilter.approved)
        return item.status == 'approved';
      if (_filter == _ContributionFilter.rejected)
        return item.status == 'rejected';
      return true;
    }).toList();

    result.sort((a, b) {
      if (_sort == _ContributionSort.status) {
        return a.status.compareTo(b.status);
      }
      final ad = a.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return _sort == _ContributionSort.newest
          ? bd.compareTo(ad)
          : ad.compareTo(bd);
    });

    return result;
  }

  Future<void> _openContributionDetail(
    profile_model.ContributedPlace place,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContributionDetailScreen(contribution: place),
      ),
    );

    if (!mounted) return;

    if (place.status == 'rejected') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResubmitContributionScreen(contribution: place),
        ),
      );
      if (!mounted) return;
    }

    _refreshContributionViews();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return _l10n.approved;
      case 'rejected':
        return _l10n.rejected;
      default:
        return _l10n.pendingReview;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildLeaderboardAndImpact(profile_model.UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_l10n.globalRankPrefix} #${profile.leaderboardRank}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '${_l10n.impactPrefix} ${profile.impactCount} ${_l10n.impactSuffix}',
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
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.leaderboardLoadError),
          const SizedBox(height: 4),
          Text(
            _buildErrorUi(error).message,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _retryAll,
            icon: const Icon(Icons.refresh),
            label: Text(_l10n.retryLeaderboard),
          ),
        ],
      ),
      data: (contributors) {
        if (contributors.isEmpty) {
          return Text(_l10n.noLeaderboardDataYet);
        }

        final top = contributors.take(5).toList();
        return Column(
          children: top.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final name = (item['userName'] ?? _l10n.unknown).toString();
            final count = (item['approvedCount'] ?? 0).toString();

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 14, child: Text('$rank')),
              title: Text(name),
              trailing: Text('$count ${_l10n.approvedSuffix}'),
            );
          }).toList(),
        );
      },
    );
  }

  _ErrorUiData _buildErrorUi(Object error) {
    if (error is ProfileLoadException) {
      switch (error.type) {
        case ProfileLoadErrorType.authLoading:
          return _ErrorUiData(
            title: _l10n.preparingSessionTitle,
            message: _l10n.preparingSessionMessage,
          );
        case ProfileLoadErrorType.missingToken:
          return _ErrorUiData(
            title: _l10n.signInRequiredTitle,
            message: _l10n.signInRequiredMessage,
            showSignInAction: true,
          );
        case ProfileLoadErrorType.expiredToken:
          return _ErrorUiData(
            title: _l10n.sessionExpiredTitle,
            message: _l10n.sessionExpiredMessage,
            showSignInAction: true,
          );
        case ProfileLoadErrorType.userNotRegistered:
          return _ErrorUiData(
            title: _l10n.creatingProfileTitle,
            message: _l10n.creatingProfileMessage,
          );
        case ProfileLoadErrorType.offline:
          return _ErrorUiData(
            title: _l10n.noInternetTitle,
            message: _l10n.noInternetMessage,
          );
        case ProfileLoadErrorType.forbidden:
          return _ErrorUiData(
            title: _l10n.accessDeniedTitle,
            message: _l10n.accessDeniedMessage,
          );
        case ProfileLoadErrorType.server:
          return _ErrorUiData(
            title: _l10n.serverErrorTitle,
            message: _l10n.serverErrorMessage,
          );
        case ProfileLoadErrorType.unknown:
          return _ErrorUiData(
            title: _l10n.unableLoadProfileTitle,
            message: _l10n.unableLoadProfileMessage,
          );
      }
    }

    final message = error.toString().toLowerCase();
    if (message.contains('401') || message.contains('unauthorized')) {
      return _ErrorUiData(
        title: _l10n.sessionExpiredTitle,
        message: _l10n.sessionExpiredMessage,
        showSignInAction: true,
      );
    }

    return _ErrorUiData(
      title: _l10n.errorLoadingProfileTitle,
      message: _l10n.errorLoadingProfileMessage,
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
        ],
      ),
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

  String _cacheBustedAvatar(String url) {
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}v=${DateTime.now().millisecondsSinceEpoch ~/ 60000}';
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.logoutConfirmTitle),
        content: Text(_l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: Text(_l10n.logout),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_l10n.errorPrefix} $e')));
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
