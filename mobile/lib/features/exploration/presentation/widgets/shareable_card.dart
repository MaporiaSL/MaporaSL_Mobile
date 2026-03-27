import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/exploration_models.dart';

class ShareableCard extends StatelessWidget {
  final DistrictAssignment? assignment;
  final ExplorationLocation? location;
  final String? unlockLocationName;
  final int totalXp;
  final int totalVisited;
  final int currentLevel;

  const ShareableCard({
    super.key,
    this.assignment,
    this.location,
    this.unlockLocationName,
    this.totalXp = 0,
    this.totalVisited = 0,
    this.currentLevel = 1,
  }) : assert(assignment != null || location != null);

  List<ExplorationLocation> get _displayLocations =>
      location != null ? [location!] : (assignment?.locations ?? []);

  Set<String> get _visitedIds => location != null
      ? {location!.id}
      : (assignment?.locations
              .where((l) => l.visited)
              .map((l) => l.id)
              .toSet() ??
          {});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(DateTime.now());

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.9).clamp(320.0, 420.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B3B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Certificate of Discovery',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'MAPORIA',
                style: TextStyle(
                  color: Color(0xFF7DD3FC),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            location?.name ?? assignment?.district ?? 'Unknown Place',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            location != null
                ? '${location!.category ?? 'Destination'} in ${location!.type}'
                : '${assignment?.visitedCount ?? 0}/${assignment?.assignedCount ?? 0} Places Visited in ${assignment?.district ?? ''}',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (unlockLocationName != null) ...[
            const SizedBox(height: 6),
            Text(
              'Final verification at $unlockLocationName',
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF93C5FD),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatRow(Icons.workspace_premium, 'Total Explorer XP', '$totalXp', Colors.amber),
                const Divider(color: Colors.white24, height: 1),
                _buildStatRow(Icons.place, 'Places Discovered', '$totalVisited', const Color(0xFF22C55E)),
                const Divider(color: Colors.white24, height: 1),
                _buildStatRow(Icons.military_tech, 'Explorer Level', 'Lvl $currentLevel', const Color(0xFF38BDF8)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlocked: $formattedDate',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan to explore maporiasl.com',
                      style: textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: 'https://maporiasl.com',
                  size: 72,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniPathMap extends StatelessWidget {
  final List<ExplorationLocation> points;
  final Set<String> visitedIds;

  const MiniPathMap({
    super.key,
    required this.points,
    required this.visitedIds,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniPathMapPainter(points: points, visitedIds: visitedIds),
      child: const SizedBox.expand(),
    );
  }
}

class _MiniPathMapPainter extends CustomPainter {
  final List<ExplorationLocation> points;
  final Set<String> visitedIds;

  _MiniPathMapPainter({required this.points, required this.visitedIds});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0x1422D3EE)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      bgPaint,
    );

    if (points.isEmpty) return;

    final latitudes = points.map((point) => point.latitude).toList();
    final longitudes = points.map((point) => point.longitude).toList();
    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLng = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

    final latSpan = (maxLat - minLat).abs() < 0.0001
        ? 0.0001
        : (maxLat - minLat);
    final lngSpan = (maxLng - minLng).abs() < 0.0001
        ? 0.0001
        : (maxLng - minLng);

    Offset toOffset(ExplorationLocation point) {
      const pad = 14.0;
      final usableW = size.width - (pad * 2);
      final usableH = size.height - (pad * 2);
      final x = ((point.longitude - minLng) / lngSpan) * usableW + pad;
      final y =
          size.height - (((point.latitude - minLat) / latSpan) * usableH + pad);
      return Offset(x, y);
    }

    final visitedPoints = points
        .where((p) => visitedIds.contains(p.id))
        .toList();

    if (visitedPoints.length > 1) {
      final path = Path()
        ..moveTo(
          toOffset(visitedPoints.first).dx,
          toOffset(visitedPoints.first).dy,
        );
      for (var i = 1; i < visitedPoints.length; i++) {
        final p = toOffset(visitedPoints[i]);
        path.lineTo(p.dx, p.dy);
      }
      final linePaint = Paint()
        ..color = const Color(0xFF22D3EE)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }

    for (final point in points) {
      final offset = toOffset(point);
      final visited = visitedIds.contains(point.id);
      final dotPaint = Paint()
        ..color = visited ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, visited ? 5.0 : 4.0, dotPaint);

      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7;
      canvas.drawCircle(offset, visited ? 7.0 : 6.0, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPathMapPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.visitedIds != visitedIds;
  }
}

class DiscoveryCertificateOverlay extends StatefulWidget {
  final DistrictAssignment? assignment;
  final ExplorationLocation? location;
  final String? unlockLocationName;
  final int totalXp;
  final int totalVisited;
  final int currentLevel;

  const DiscoveryCertificateOverlay({
    super.key,
    this.assignment,
    this.location,
    this.unlockLocationName,
    this.totalXp = 0,
    this.totalVisited = 0,
    this.currentLevel = 1,
  });

  @override
  State<DiscoveryCertificateOverlay> createState() =>
      _DiscoveryCertificateOverlayState();
}

class _DiscoveryCertificateOverlayState
    extends State<DiscoveryCertificateOverlay> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<Uint8List?> _captureCardPng() async {
    final context = _cardKey.currentContext;
    if (context == null) return null;

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final pngBytes = await _captureCardPng();
      if (pngBytes == null) return;

      final dir = await getTemporaryDirectory();
      final name = widget.location?.name ?? widget.assignment?.district ?? 'place';
      final safeName = name.toLowerCase().replaceAll(
        ' ',
        '_',
      );
      final file = File('${dir.path}/maporia_${safeName}_discovery.png');
      await file.writeAsBytes(pngBytes, flush: true);

      final shareText = widget.location != null
          ? 'I discovered ${widget.location!.name} on MAPORIA! #MaporiaDiscovery'
          : 'I unlocked ${widget.assignment!.district} on MAPORIA. #MaporiaDiscovery';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Stack(
        children: [
          // Background Tap-to-Close
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Prevent tap-through to background
                        child: RepaintBoundary(
                          key: _cardKey,
                          child: ShareableCard(
                            assignment: widget.assignment,
                            location: widget.location,
                            unlockLocationName: widget.unlockLocationName,
                            totalXp: widget.totalXp,
                            totalVisited: widget.totalVisited,
                            currentLevel: widget.currentLevel,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _shareCard,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSharing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.share),
                        label: Text(
                          _isSharing ? 'Generating image...' : 'Share Certificate',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
