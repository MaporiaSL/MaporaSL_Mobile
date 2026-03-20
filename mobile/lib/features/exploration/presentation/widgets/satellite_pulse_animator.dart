import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Satellite Pulse Sync Animator
/// Real-time visual feedback showing GPS verification as satellite data handshake
/// Features:
/// - Concentric expanding rings (pulses) from user location
/// - Data streams (glowing lines) from location marker back to center
/// - District map color-in effect on verification completion
/// - XP counter flying animation
/// - Sound design integration points

class SatellitePulseSyncAnimator extends StatefulWidget {
  final Duration duration;
  final VoidCallback onPulseComplete;
  final int pulseCount;
  final double centerLat;
  final double centerLng;
  final List<VerificationTargetLocation> targetLocations;
  final bool isVerifying;

  const SatellitePulseSyncAnimator({
    super.key,
    required this.duration,
    required this.onPulseComplete,
    this.pulseCount = 3,
    required this.centerLat,
    required this.centerLng,
    required this.targetLocations,
    required this.isVerifying,
  });

  @override
  State<SatellitePulseSyncAnimator> createState() =>
      _SatellitePulseSyncAnimatorState();
}

class _SatellitePulseSyncAnimatorState extends State<SatellitePulseSyncAnimator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dataStreamController;
  late List<AnimationController> _ringControllers;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dataStreamAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _dataStreamController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ringControllers = List.generate(
      widget.pulseCount,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(_pulseController);
    _dataStreamAnimation =
        Tween<double>(begin: 0, end: 1).animate(_dataStreamController);

    if (widget.isVerifying) {
      _startPulseSequence();
    }
  }

  void _startPulseSequence() {
    for (int i = 0; i < _ringControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          _ringControllers[i].forward().then((_) {
            if (i == _ringControllers.length - 1) {
              _startDataStream();
            }
          });
        }
      });
    }
  }

  void _startDataStream() {
    _dataStreamController.forward().then((_) {
      widget.onPulseComplete();
    });
  }

  @override
  void didUpdateWidget(covariant SatellitePulseSyncAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVerifying && !oldWidget.isVerifying) {
      _startPulseSequence();
    }
    if (!widget.isVerifying && oldWidget.isVerifying) {
      _pulseController.stop();
      _dataStreamController.stop();
      for (final controller in _ringControllers) {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dataStreamController.dispose();
    for (final controller in _ringControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SatellitePulsePainter(
        pulseAnimation: _pulseAnimation,
        dataStreamAnimation: _dataStreamAnimation,
        ringAnimations:
            _ringControllers.map((c) => c.view as Animation<double>).toList(),
        centerLat: widget.centerLat,
        centerLng: widget.centerLng,
        targetLocations: widget.targetLocations,
        isVerifying: widget.isVerifying,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SatellitePulsePainter extends CustomPainter {
  final Animation<double> pulseAnimation;
  final Animation<double> dataStreamAnimation;
  final List<Animation<double>> ringAnimations;
  final double centerLat;
  final double centerLng;
  final List<VerificationTargetLocation> targetLocations;
  final bool isVerifying;

  _SatellitePulsePainter({
    required this.pulseAnimation,
    required this.dataStreamAnimation,
    required this.ringAnimations,
    required this.centerLat,
    required this.centerLng,
    required this.targetLocations,
    required this.isVerifying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = Offset(size.width / 2, size.height / 2);
    const maxRadius = 200.0;

    // Draw background gradient
    final bgGradient = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x0F22D3EE),
          const Color(0x0006B6D4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: centerOffset, radius: maxRadius));
    canvas.drawCircle(centerOffset, maxRadius, bgGradient);

    // Draw expanding rings (pulses) from center
    for (int i = 0; i < ringAnimations.length; i++) {
      final ringProgress = ringAnimations[i].value;
      final ringRadius = ringProgress * maxRadius;
      final ringOpacity = (1 - ringProgress) * 0.8;

      final ringPaint = Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(centerOffset, ringRadius, ringPaint);

      // Draw outer glow
      final glowPaint = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: ringOpacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

      canvas.drawCircle(centerOffset, ringRadius, glowPaint);
    }

    // Draw user location marker (blue dot)
    final userMarkerPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerOffset, 8, userMarkerPaint);

    final userMarkerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(centerOffset, 12, userMarkerRingPaint);

    // Draw data streams from target locations back to center
    if (dataStreamAnimation.value > 0) {
      for (final target in targetLocations) {
        final targetScreenPos = _latLngToScreen(
          target.latitude,
          target.longitude,
          centerLat,
          centerLng,
          size,
        );

        // Animated line progress from target to center
        final streamProgress = dataStreamAnimation.value;
        final startPoint = Offset.lerp(targetScreenPos, centerOffset, streamProgress)!;

        // Draw glowing data stream line
        final streamPaint = Paint()
          ..color = const Color(0xFF22D3EE).withValues(alpha: streamProgress * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(targetScreenPos, startPoint, streamPaint);

        // Draw trailing glow
        final glowPaint = Paint()
          ..color = const Color(0xFF06B6D4).withValues(alpha: streamProgress * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

        canvas.drawLine(targetScreenPos, startPoint, glowPaint);
      }
    }

    // Draw target location markers
    for (final target in targetLocations) {
      final targetScreenPos = _latLngToScreen(
        target.latitude,
        target.longitude,
        centerLat,
        centerLng,
        size,
      );

      final targetMarkerPaint = Paint()
        ..color = target.isVisited
            ? const Color(0xFF22C55E)
            : const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(targetScreenPos, 6, targetMarkerPaint);

      final targetRingPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(targetScreenPos, 8.5, targetRingPaint);
    }
  }

  Offset _latLngToScreen(
    double lat,
    double lng,
    double centerLat,
    double centerLng,
    Size size,
  ) {
    // Simple mercator-like projection for demo purposes
    const scale = 50000; // Adjust based on zoom level
    final x = size.width / 2 + (lng - centerLng) * scale;
    final y = size.height / 2 - (lat - centerLat) * scale;
    return Offset(x.clamp(0, size.width), y.clamp(0, size.height));
  }

  @override
  bool shouldRepaint(covariant _SatellitePulsePainter oldDelegate) {
    return oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.dataStreamAnimation != dataStreamAnimation ||
        oldDelegate.isVerifying != isVerifying;
  }
}

class VerificationTargetLocation {
  final double latitude;
  final double longitude;
  final bool isVisited;
  final String name;

  VerificationTargetLocation({
    required this.latitude,
    required this.longitude,
    required this.isVisited,
    required this.name,
  });
}

/// XP Counting Animation
/// Animates XP points flying from unlock location to top-right corner XP total
class XPCountingAnimation extends StatefulWidget {
  final int xpAmount;
  final Offset fromPosition;
  final Duration duration;
  final VoidCallback onComplete;

  const XPCountingAnimation({
    super.key,
    required this.xpAmount,
    required this.fromPosition,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<XPCountingAnimation> createState() => _XPCountingAnimationState();
}

class _XPCountingAnimationState extends State<XPCountingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.fromPosition,
      end: const Offset(-20, -40), // Top-right corner offset
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _slideAnimation.value.dx,
          top: _slideAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: 1.0 + (1.0 - _opacityAnimation.value) * 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    )
                  ],
                ),
                child: Text(
                  '+${widget.xpAmount} XP',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Digital Coordinate Counter
/// Displays GPS coordinates scrolling and locking into place
class DigitalCoordinateCounter extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Duration lockDuration;
  final bool isLocked;

  const DigitalCoordinateCounter({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.lockDuration,
    required this.isLocked,
  });

  @override
  State<DigitalCoordinateCounter> createState() =>
      _DigitalCoordinateCounterState();
}

class _DigitalCoordinateCounterState extends State<DigitalCoordinateCounter>
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late AnimationController _lockController;
  late Animation<int> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _lockController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scrollAnimation = IntTween(begin: 0, end: 100000).animate(
      CurvedAnimation(parent: _scrollController, curve: Curves.linear),
    );

    if (!widget.isLocked) {
      _scrollController.repeat();
    } else {
      _scrollController.stop();
      _lockController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant DigitalCoordinateCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocked && !oldWidget.isLocked) {
      _scrollController.stop();
      _lockController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Latitude display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            border: Border.all(
              color: widget.isLocked
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF22D3EE)
                  .withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedBuilder(
            animation: _lockController,
            builder: (context, child) {
              final scale = 1.0 + (_lockController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: Text(
                  'LAT: ${widget.latitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: widget.isLocked
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF22D3EE),
                    fontFamily: 'Courier New',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Longitude display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            border: Border.all(
              color: widget.isLocked
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF22D3EE)
                  .withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedBuilder(
            animation: _lockController,
            builder: (context, child) {
              final scale = 1.0 + (_lockController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: Text(
                  'LNG: ${widget.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: widget.isLocked
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF22D3EE),
                    fontFamily: 'Courier New',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
