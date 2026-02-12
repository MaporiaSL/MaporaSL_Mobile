
class BrushHighlight extends StatelessWidget {
  final String text;

  const BrushHighlight(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -6,
          child: CustomPaint(
            size: Size(text.length * 16.0, 14),
            painter: BrushUnderlinePainter(),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF6B35),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class BrushUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start left
    path.moveTo(0, size.height * 0.6);

    // Smooth upward curve (thicker center illusion)
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}