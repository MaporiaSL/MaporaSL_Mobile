import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/exploration/data/models/exploration_models.dart';
import '../../../../features/exploration/providers/exploration_provider.dart';
import '../../../../features/exploration/presentation/widgets/shareable_card.dart';
import '../../../../features/exploration/presentation/widgets/satellite_pulse_animator.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../providers/visit_provider.dart';
import './verification_checklist.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class DynamicVisitSheet extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;
  final double targetLat;
  final double targetLng;

  final bool isExploration;
  final ExplorationLocation? explorationLocation;

  const DynamicVisitSheet({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.targetLat,
    required this.targetLng,
    this.isExploration = false,
    this.explorationLocation,
  });

  @override
  ConsumerState<DynamicVisitSheet> createState() => _DynamicVisitSheetState();

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String placeId,
    required String placeName,
    required double targetLat,
    required double targetLng,
    bool isExploration = false,
    ExplorationLocation? explorationLocation,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicVisitSheet(
        placeId: placeId,
        placeName: placeName,
        targetLat: targetLat,
        targetLng: targetLng,
        isExploration: isExploration,
        explorationLocation: explorationLocation,
      ),
    );
  }
}

class _DynamicVisitSheetState extends ConsumerState<DynamicVisitSheet>
    with SingleTickerProviderStateMixin {
  List<VerificationStep> _steps = [];
  int _currentStepIndex = 0;
  late AnimationController _radarController;
  late ConfettiController _confettiController;
  bool _wasDistrictUnlocked = false;
  bool _certificateShown = false;
  List<VerificationTargetLocation> _targetLocations = [];
  int _xpAwarded = 0;
  @override
  void initState() {
    super.initState();
    final useAnimations = ref.read(accessibilityProvider).useAnimations;
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (useAnimations) {
      _radarController.repeat();
    }

    _initSteps();

    // Prepare target locations for satellite pulse animation
    if (widget.isExploration && widget.explorationLocation != null) {
      _targetLocations = [
        VerificationTargetLocation(
          latitude: widget.explorationLocation!.latitude,
          longitude: widget.explorationLocation!.longitude,
          isVisited: false,
          name: widget.placeName,
        ),
      ];
    }

    if (widget.isExploration && widget.explorationLocation != null) {
      final assignment = _findAssignmentForLocation(
        ref.read(explorationProvider),
      );
      _wasDistrictUnlocked = assignment?.isUnlocked == true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerVerification();
    });
  }

  DistrictAssignment? _findAssignmentForLocation(ExplorationState state) {
    final target = widget.explorationLocation?.id;
    if (target == null || target.isEmpty) return null;

    for (final assignment in state.assignments) {
      final hasLocation = assignment.locations.any(
        (location) => location.id == target,
      );
      if (hasLocation) return assignment;
    }
    return null;
  }

  Future<void> _openCertificateOverlay({
    DistrictAssignment? assignment,
    ExplorationLocation? location,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return DiscoveryCertificateOverlay(
            assignment: assignment,
            location: location,
            unlockLocationName: widget.placeName,
          );
        },
      ),
    );
  }

  void _initSteps() {
    _steps = [
      VerificationStep(
        label: 'Satellite Signal Strength',
        icon: Icons.wifi_tethering,
      ),
      VerificationStep(
        label: 'Main Geofence Boundary Check',
        icon: Icons.adjust,
      ),
      VerificationStep(
        label: 'Multi-Path Reflection Correction',
        icon: Icons.reorder,
      ),
      VerificationStep(
        label: 'Atmospheric Data Validation',
        icon: Icons.cloud_done,
      ),
      VerificationStep(label: 'Proximity Finalization', icon: Icons.fact_check),
    ];
  }

  void _triggerVerification() {
    if (widget.isExploration && widget.explorationLocation != null) {
      ref
          .read(explorationProvider.notifier)
          .verifyLocation(widget.explorationLocation!);
    } else {
      ref
          .read(visitProvider.notifier)
          .markVisitWithDeviceLocation(
            widget.placeId,
            widget.targetLat,
            widget.targetLng,
          );
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitProvider);
    final explorationState = ref.watch(explorationProvider);

    // Abstract the state for the UI
    final bool isVerifying = widget.isExploration
        ? explorationState.isVerifying
        : visitState.isVerifying;
        
    final bool success = widget.isExploration
        ? (!explorationState.isVerifying && explorationState.currentStepIndex == _steps.length)
        : visitState.success;
        
    final String? error = widget.isExploration
        ? explorationState.error
        : visitState.error;
        
    final int providerStepIndex = widget.isExploration
        ? (success ? _steps.length : explorationState.currentStepIndex)
        : (success ? _steps.length : visitState.currentStepIndex);
    final String? verificationStepDesc = widget.isExploration
        ? explorationState.verificationStep
        : visitState.verificationStep;
    final currentAssignment = widget.isExploration
        ? _findAssignmentForLocation(explorationState)
        : null;
    final districtJustUnlocked =
        widget.isExploration &&
        currentAssignment != null &&
        currentAssignment.isUnlocked &&
        !_wasDistrictUnlocked &&
        success &&
        error == null;

    // Celebrations moved to MapScreen. We just check if we need to auto-pop.
    if (success && widget.isExploration && !_certificateShown) {
      _certificateShown = true;
      int xpAwarded = districtJustUnlocked ? 25 : 10;
      xpAwarded += math.Random().nextInt(5);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop({
            'success': true,
            'districtJustUnlocked': districtJustUnlocked,
            'assignment': currentAssignment,
            'location': widget.explorationLocation,
            'xpAwarded': xpAwarded,
          });
        }
      });
    }

    // Sync _steps with provider state
    for (int i = 0; i < _steps.length; i++) {
      if (error != null && providerStepIndex == i) {
        _steps[i].status = StepStatus.failed;
      } else if (providerStepIndex > i || success) {
        _steps[i].status = StepStatus.passed;
      } else if (providerStepIndex == i && isVerifying) {
        _steps[i].status = StepStatus.checking;
      } else {
        _steps[i].status = StepStatus.pending;
      }
    }
    _currentStepIndex = providerStepIndex;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                  Colors.cyan,
                  Colors.lime,
                ],
                createParticlePath: _drawStar,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildContent(
                      isVerifying,
                      success,
                      error,
                      verificationStepDesc,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    bool isVerifying,
    bool success,
    String? error,
    String? stepDesc,
  ) {
    final explorationState = ref.watch(explorationProvider);
    final currentAssignment = widget.isExploration
        ? _findAssignmentForLocation(explorationState)
        : null;
    final districtJustUnlocked =
        widget.isExploration &&
        currentAssignment != null &&
        currentAssignment.isUnlocked &&
        !_wasDistrictUnlocked &&
        success &&
        error == null;

    if (isVerifying ||
        (error == null && !success &&
            _currentStepIndex < _steps.length &&
            _currentStepIndex >= 0)) {
      return _buildVerifyingUI(stepDesc);
    } else if (success) {
      if (widget.isExploration) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return _buildSuccessUI(
          districtJustUnlocked: districtJustUnlocked,
          currentAssignment: currentAssignment,
        );
      }
    } else if (error != null) {
      return _buildErrorUI(error);
    }
    return _buildVerifyingUI(stepDesc); // Default while starting
  }

  Widget _buildVerifyingUI(String? stepDesc) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Satellite Pulse Sync Animation (replace radar)
              if (widget.isExploration && _targetLocations.isNotEmpty)
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SatellitePulseSyncAnimator(
                      duration: const Duration(seconds: 3),
                      onPulseComplete: () {
                        // Audio cue plays here (digital chime)
                      },
                      pulseCount: 3,
                      centerLat: widget.targetLat,
                      centerLng: widget.targetLng,
                      targetLocations: _targetLocations,
                      isVerifying: true,
                    ),
                  ),
                )
              else
                // Fallback radar for non-exploration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _radarController.value * 2 * math.pi,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.blue.withValues(alpha: 0.0),
                                  Colors.blue.withValues(alpha: 0.5),
                                  Colors.blue.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_searching,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              // Digital Coordinate Counter
              if (widget.isExploration)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DigitalCoordinateCounter(
                    latitude: widget.targetLat,
                    longitude: widget.targetLng,
                    lockDuration: const Duration(milliseconds: 600),
                    isLocked: _currentStepIndex >= 4, // Lock after 4th step
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                stepDesc ?? 'Deep Verification In Progress',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: VerificationChecklist(
                  steps: _steps,
                  currentStepIndex: _currentStepIndex,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessUI({
    required bool districtJustUnlocked,
    required DistrictAssignment? currentAssignment,
  }) {
    // Extract XP amount from exploration state if available
    if (widget.isExploration) {
      // Award XP for any successful discovery
      _xpAwarded = districtJustUnlocked ? 25 : 10;
      _xpAwarded += math.Random().nextInt(5);
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: ref.watch(accessibilityProvider).useAnimations
                    ? const Duration(milliseconds: 600)
                    : Duration.zero,
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        districtJustUnlocked ? Icons.flag : Icons.check_circle,
                        size: 60,
                        color: districtJustUnlocked
                            ? Colors.amber
                            : Colors.teal,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                districtJustUnlocked
                    ? 'DISTRICT UNLOCKED!'
                    : 'NEW DISCOVERY!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  districtJustUnlocked
                      ? 'Congratulations! You have mastered the entire ${currentAssignment?.district ?? ''} district.'
                      : 'You just unlocked ${widget.placeName}! A new certificate has been added to your collection.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (districtJustUnlocked && _xpAwarded > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFB84D),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '+$_xpAwarded XP',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
              if (widget.isExploration) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openCertificateOverlay(
                        assignment: currentAssignment,
                        location: currentAssignment == null || districtJustUnlocked ? null : widget.explorationLocation,
                      );
                    },
                    icon: const Icon(Icons.share, size: 20),
                    label: Text(
                      districtJustUnlocked ? 'SHARE DISTRICT MEDAL' : 'SHARE DISCOVERY CARD',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text('BACK TO MAP', style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                )),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        // XP Flying Animation (if unlocked)
        if (districtJustUnlocked && _xpAwarded > 0)
          XPCountingAnimation(
            xpAmount: _xpAwarded,
            fromPosition: const Offset(140, 300), // Center of screen
            duration: const Duration(milliseconds: 1200),
            onComplete: () {},
          ),
      ],
    );
  }

  Widget _buildErrorUI(String errorMsg) {
    // Make error messages more user-friendly
    String displayError = errorMsg;
    
    // If we have a specific rejection reason from the location, use it
    if (widget.isExploration && widget.explorationLocation != null) {
      final explorationState = ref.watch(explorationProvider);
      final location = explorationState.assignments
          .expand((a) => a.locations)
          .firstWhere((l) => l.id == widget.explorationLocation!.id, 
                    orElse: () => widget.explorationLocation!);
      
      if (location.rejectionReason != null) {
        displayError = location.rejectionReason!;
      }
    }

    final lowerError = displayError.toLowerCase();
    if (lowerError.contains('not enough valid gps samples') ||
        lowerError.contains('gps') ||
        lowerError.contains('accuracy')) {
      displayError =
          'Poor GPS signal. Please ensure you are outdoors with a clear view of the sky and try again.';
    } else if (lowerError.contains('too far')) {
      displayError =
          'You appear to be too far from the location. Please get closer and try verifying again.';
    } else if (lowerError.contains('timeout') ||
        lowerError.contains('connection') || 
        lowerError.contains('dioexception')) {
      displayError =
          'Network error. Please check your internet connection and try again.';
    } else if (lowerError.contains('cooldown') || lowerError.contains('429')) {
      displayError = 'Verification cooldown active. Please wait a few minutes before trying again.';
    } else if (displayError.length > 80) {
      displayError = 'Verification failed. Please ensure you are at the correct location and try again.';
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Show the checklist showing where it failed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: VerificationChecklist(
              steps: _steps,
              currentStepIndex: _currentStepIndex,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(indent: 40, endIndent: 40),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text(
            'Verification Failed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              displayError,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade800,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {
              if (widget.isExploration && widget.explorationLocation != null) {
                ref
                    .read(explorationProvider.notifier)
                    .verifyLocation(widget.explorationLocation!);
              } else {
                ref.read(visitProvider.notifier).reset();
                ref
                    .read(visitProvider.notifier)
                    .markVisitWithDeviceLocation(
                      widget.placeId,
                      widget.targetLat,
                      widget.targetLng,
                    );
              }
              setState(() {
                _initSteps();
                _triggerVerification();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    // Method to draw a star shape
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}
