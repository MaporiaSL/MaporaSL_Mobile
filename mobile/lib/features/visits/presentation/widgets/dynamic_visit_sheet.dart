import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/visit_provider.dart';
import '../../../../features/exploration/data/models/exploration_models.dart';
import '../../../../features/exploration/providers/exploration_provider.dart';
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
  List<_VerificationStep> _steps = [];
  int _currentStepIndex = 0;
  bool _isFailsafeActive = false;
  late AnimationController _radarController; // Added declaration

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    _initSteps();
    _startVerificationSequence();
  }

  void _initSteps() {
    _steps = [
      _VerificationStep(label: 'Satellite Signal Strength', icon: Icons.wifi_tethering),
      _VerificationStep(label: 'Main Geofence Boundary Check', icon: Icons.adjust),
      _VerificationStep(label: 'Multi-Path Reflection Correction', icon: Icons.reorder),
      _VerificationStep(label: 'Atmospheric Data Validation', icon: Icons.cloud_done),
      _VerificationStep(label: 'Proximity Finalization', icon: Icons.fact_check),
    ];
  }

  Future<void> _startVerificationSequence() async {
    // 1. Kick off the actual API call in the background
    if (widget.isExploration && widget.explorationLocation != null) {
      ref.read(explorationProvider.notifier).verifyLocation(widget.explorationLocation!);
    } else {
      ref.read(visitProvider.notifier).markVisitWithDeviceLocation(
        widget.placeId,
        widget.targetLat,
        widget.targetLng,
      );
    }

    // 2. Animate the checklist steps
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _currentStepIndex = i;
        _steps[i].status = StepStatus.checking;
      });

      // Artificial delay for premium feel
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      setState(() {
        _steps[i].status = StepStatus.passed;
      });
      
      // If we are at the "Main Geofence" step, let's pretend to check failsafe if needed?
      // Actually, the user just wants it to look like it's doing work.
      // But we can check the provider state here to sync if it's already failed.
      final state = ref.read(visitProvider);
      if (state.error != null && i >= 1) {
         // If already failed, we stop early
         break;
      }
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
        ? (explorationState.verifyingLocationId == null && explorationState.error == null && !explorationState.isVerifying) 
        : visitState.success;
    final String? error = widget.isExploration ? explorationState.error : visitState.error;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6, // Increased height for list
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: _buildStateContent(visitState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateContent(VisitState state) {
    if (state.isVerifying || (_currentStepIndex < _steps.length - 1 && state.error == null)) {
      return _buildVerifyingUI();
    } else if (state.success) {
      return _buildSuccessUI();
    } else if (state.error != null) {
      return _buildErrorUI(state.error!);
    }
    return const SizedBox();
  }

  Widget _buildVerifyingUI() {
    return Column(
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
                          Colors.blue.withOpacity(0.0),
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.0),
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
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
            ),
            const Icon(Icons.location_searching, size: 30, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Deep Verification In Progress',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _buildStepItem(step, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(_VerificationStep step, int index) {
    final isActive = index == _currentStepIndex;
    final isDone = step.status == StepStatus.passed;
    final isChecking = step.status == StepStatus.checking;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: (index <= _currentStepIndex) ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? Colors.teal.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_circle : (isChecking ? Icons.sync : step.icon),
                size: 20,
                color: isDone ? Colors.teal : (isChecking ? Colors.blue : Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                step.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? Colors.teal : (isActive ? Colors.blue : Colors.grey.shade600),
                ),
              ),
            ),
            if (isChecking)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.2),
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
      ],
    );
  }

  Widget _buildErrorUI(String errorMsg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.1),
          ),
          child: const Icon(Icons.error_outline, size: 60, color: Colors.red),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verification Failed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            errorMsg,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
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
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          child: const Text('Try Again', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

enum StepStatus { idle, checking, passed, failed }

class _VerificationStep {
  final String label;
  final IconData icon;
  StepStatus status;

  _VerificationStep({
    required this.label,
    required this.icon,
    this.status = StepStatus.idle,
  });
}
