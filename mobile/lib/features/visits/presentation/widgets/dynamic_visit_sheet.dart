import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/exploration/data/models/exploration_models.dart';
import '../../../../features/exploration/providers/exploration_provider.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../providers/visit_provider.dart';
import './verification_checklist.dart';
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

  static void show(BuildContext context, {
    required String placeId,
    required String placeName,
    required double targetLat,
    required double targetLng,
    bool isExploration = false,
    ExplorationLocation? explorationLocation,
  }) {
    showModalBottomSheet(
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

  @override
  void initState() {
    super.initState();
    final useAnimations = ref.read(accessibilityProvider).useAnimations;
    _radarController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    
    if (useAnimations) {
      _radarController.repeat();
    }
    
    _initSteps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerVerification();
    });
  }

  void _initSteps() {
    _steps = [
      VerificationStep(label: 'Satellite Signal Strength', icon: Icons.wifi_tethering),
      VerificationStep(label: 'Main Geofence Boundary Check', icon: Icons.adjust),
      VerificationStep(label: 'Multi-Path Reflection Correction', icon: Icons.reorder),
      VerificationStep(label: 'Atmospheric Data Validation', icon: Icons.cloud_done),
      VerificationStep(label: 'Proximity Finalization', icon: Icons.fact_check),
    ];
  }

  void _triggerVerification() {
    if (widget.isExploration && widget.explorationLocation != null) {
      ref.read(explorationProvider.notifier).verifyLocation(widget.explorationLocation!);
    } else {
      ref.read(visitProvider.notifier).markVisitWithDeviceLocation(
        widget.placeId,
        widget.targetLat,
        widget.targetLng,
      );
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitProvider);
    final explorationState = ref.watch(explorationProvider);
    
    // Abstract the state for the UI
    final bool isVerifying = widget.isExploration ? explorationState.isVerifying : visitState.isVerifying;
    final bool success = widget.isExploration 
        ? (explorationState.verifyingLocationId == null && explorationState.error == null && !explorationState.isVerifying && explorationState.currentStepIndex == 5) 
        : visitState.success;
    final String? error = widget.isExploration ? explorationState.error : visitState.error;
    final int providerStepIndex = widget.isExploration ? explorationState.currentStepIndex : visitState.currentStepIndex;
    final String? verificationStepDesc = widget.isExploration ? explorationState.verificationStep : visitState.verificationStep;

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
            )
          ],
        ),
        child: Column(
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildContent(isVerifying, success, error, verificationStepDesc),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isVerifying, bool success, String? error, String? stepDesc) {
    if (isVerifying || (error == null && _currentStepIndex < _steps.length && _currentStepIndex >= 0)) {
      return _buildVerifyingUI(stepDesc);
    } else if (success && error == null) {
      return _buildSuccessUI();
    } else if (error != null) {
      return _buildErrorUI(error);
    }
    return _buildVerifyingUI(stepDesc); // Default while starting
  }

  Widget _buildVerifyingUI(String? stepDesc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
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
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
                ),
              ),
              const Icon(Icons.location_searching, size: 30, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            stepDesc ?? 'Deep Verification In Progress',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildSuccessUI() {
    return SingleChildScrollView(
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
                  child: const Icon(Icons.check_circle, size: 60, color: Colors.teal),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Visit Confirmed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have successfully visited ${widget.placeName}',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Awesome!', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorUI(String errorMsg) {
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
              errorMsg,
              style: TextStyle(fontSize: 14, color: Colors.red.shade800, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {
              if (widget.isExploration && widget.explorationLocation != null) {
                 ref.read(explorationProvider.notifier).verifyLocation(widget.explorationLocation!);
              } else {
                ref.read(visitProvider.notifier).reset();
                ref.read(visitProvider.notifier).markVisitWithDeviceLocation(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

