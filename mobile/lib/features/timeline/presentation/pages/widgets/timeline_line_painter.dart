import 'package:flutter/material.dart';

class TimelineLinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Color color;

  TimelineLinePainter({
    required this.isFirst,
    required this.isLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // The circle is drawn with a top margin of 24 and has a radius of 12 (plus 3px border).
    // Total vertical offset to center of circle is ~24 + 15 = 39.
    const double circleCenterY = 39.0;
    
    // Draw top line
    if (!isFirst) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, circleCenterY - 15),
        paint,
      );
    }

    // Draw bottom line
    if (!isLast) {
      canvas.drawLine(
        Offset(size.width / 2, circleCenterY + 15),
        Offset(size.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
