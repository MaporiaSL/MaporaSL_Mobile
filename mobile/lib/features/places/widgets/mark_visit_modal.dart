import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/models/place_visit.dart';
import '../providers/place_visit_provider.dart';
import './visit_verification_error_screen.dart';

/// Modal for marking a place as visited with optional notes and photos
class MarkVisitModal extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;
  final double latitude;
  final double longitude;
  final String? description;
  final String? category;

  const MarkVisitModal({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.description,
    this.category,
  });

  @override
  ConsumerState<MarkVisitModal> createState() => _MarkVisitModalState();
}

class _MarkVisitModalState extends ConsumerState<MarkVisitModal> {
  final _notesController = TextEditingController();
  bool _includeNotes = false;
  bool _agreeToVerification = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _recordVisit() async {
    if (!_agreeToVerification) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to location verification')),
      );
      return;
    }

    final userId = ref.read(userIdProvider); // TODO: Implement userIdProvider

    // Give UI time to render the loading state
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await ref
          .read(placeVisitProvider(userId).notifier)
          .recordVisit(
            placeId: widget.placeId,
            placeName: widget.placeName,
            notes: _includeNotes ? _notesController.text : null,
            placeLatitude: widget.latitude,
            placeLongitude: widget.longitude,
          );

      // Check if verification failed
      final state = ref.read(placeVisitProvider(userId));
      if (state.lastVisit != null && !state.lastVisit!.validation.isValid) {
        // Close modal and show detailed error screen
        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitVerificationErrorScreen(
                validation: state.lastVisit!.validation,
                placeName: widget.placeName,
                userLatitude: state.userLatitude ?? 0.0,
                userLongitude: state.userLongitude ?? 0.0,
                placeLatitude: widget.latitude,
                placeLongitude: widget.longitude,
                onRetry: () {
                  Navigator.pop(context);
                  // Reopen modal
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => MarkVisitModal(
                      placeId: widget.placeId,
                      placeName: widget.placeName,
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      description: widget.description,
                      category: widget.category,
                    ),
                  );
                },
              ),
            ),
          );
        }
      } else if (state.lastVisit != null &&
          state.lastVisit!.validation.isValid) {
        // Success - close modal
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Visit to ${widget.placeName} recorded!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);
    final visitState = ref.watch(placeVisitProvider(userId));

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== HEADER ==========
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify Visit',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.placeName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    if (widget.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.category!.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ========== DESCRIPTION ==========
                if (widget.description != null) ...[
                  Text(
                    widget.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ========== COORDINATES DISPLAY ==========
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Place Location',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📍 ${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ========== NOTES FIELD (OPTIONAL) ==========
                _buildNotesSection(context),

                const SizedBox(height: 20),

                // ========== ANTI-CHEAT INFORMATION ==========
                _buildAntiCheatInfo(context),

                const SizedBox(height: 20),

                // ========== AGREEMENT CHECKBOX ==========
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToVerification,
                      onChanged: (value) {
                        setState(() {
                          _agreeToVerification = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToVerification = !_agreeToVerification;
                          });
                        },
                        child: Text(
                          'I confirm I am physically at this location. Submitting false visits may result in account suspension.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ========== ERROR MESSAGE ==========
                if (visitState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            visitState.error!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (visitState.error != null) const SizedBox(height: 20),

                // ========== ACTION BUTTONS ==========
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: visitState.isVerifying
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _agreeToVerification && !visitState.isVerifying
                            ? _recordVisit
                            : null,
                        icon: visitState.isVerifying
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(
                                      context,
                                    ).primaryTextTheme.labelLarge?.color,
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          visitState.isVerifying
                              ? 'Verifying...'
                              : 'Confirm Visit',
                        ),
                      ),
                    ),
                  ],
                ),

                // ========== SUCCESS STATE ==========
                if (visitState.lastVisit != null &&
                    visitState.unlockedAchievement != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildAchievementCard(
                      visitState.unlockedAchievement!,
                      context,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ========== FULL-SCREEN VERIFICATION OVERLAY ==========
        if (visitState.isVerifying)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Verifying Visit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: visitState.verificationProgress ?? 0.0,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Current step with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStepIcon(visitState.verificationStep),
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visitState.verificationStep ??
                                      'Starting verification...',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${((visitState.verificationProgress ?? 0) * 100).toInt()}% complete',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instruction text
                      Text(
                        'Please stay still while we verify your location',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStepIcon(String? step) {
    if (step == null) return Icons.sync;
    if (step.contains('permission')) return Icons.location_on;
    if (step.contains('GPS') || step.contains('signal')) return Icons.gps_fixed;
    if (step.contains('device')) return Icons.phone_android;
    if (step.contains('security')) return Icons.security;
    if (step.contains('environmental')) return Icons.wb_sunny;
    if (step.contains('server')) return Icons.cloud_upload;
    if (step.contains('verification')) return Icons.verified_user;
    return Icons.sync;
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _includeNotes,
          onChanged: (value) {
            setState(() {
              _includeNotes = value ?? false;
            });
          },
          title: Text(
            'Add notes (optional)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (_includeNotes) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'What did you experience at this place? 📝',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counter: Text(
                '${_notesController.text.length}/500',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAntiCheatInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Security Check',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✅ GPS location verified\n✅ Device integrity checked\n✅ Timestamp secured',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    PlaceAchievement achievement,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(achievement.badgeEmoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Placeholder provider - replace with actual auth provider
final userIdProvider = Provider((ref) => 'test_user');
