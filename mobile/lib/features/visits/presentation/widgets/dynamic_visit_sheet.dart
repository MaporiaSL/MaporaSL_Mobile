import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/visit_provider.dart';
import 'dart:math' as math;

class DynamicVisitSheet extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;
  final double targetLat;
  final double targetLng;

  const DynamicVisitSheet({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.targetLat,
    required this.targetLng,
  });

  @override
  ConsumerState<DynamicVisitSheet> createState() => _DynamicVisitSheetState();

  static void show(BuildContext context, {
    required String placeId,
    required String placeName,
    required double targetLat,
    required double targetLng,
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
      ),
    );
  }
}

class _DynamicVisitSheetState extends ConsumerState<DynamicVisitSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    // Automatically start verification process using mocked user location 
    // (We will add actual geolocation later, using target location to simulate success for now)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(visitProvider.notifier).markVisitWithDeviceLocation(
        widget.placeId,
        widget.targetLat,
        widget.targetLng,
      );
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
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
    if (state.isVerifying) {
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _radarController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _radarController.value * 2 * math.pi,
                  child: Container(
                    width: 120,
                    height: 120,
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
            ),
            const Icon(Icons.location_searching, size: 40, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Verifying GPS Coordinates...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Checking proximity to ${widget.placeName}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
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
            ref.read(visitProvider.notifier).reset();
            ref.read(visitProvider.notifier).markVisitWithDeviceLocation(
              widget.placeId,
              widget.targetLat,
              widget.targetLng,
            );
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
