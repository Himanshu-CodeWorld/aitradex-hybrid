import 'package:flutter/material.dart';

class MarketCard extends StatelessWidget {
  final String title;
  final String percentage;
  final bool isPositive;

  const MarketCard({
    super.key,
    required this.title,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isPositive
        ? const Color(0xff18C48F)
        : const Color(0xffF44336);

    return Container(
      width: 119,
      height: 140,
      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        10,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // TITLE
          // ============================================================

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          // ============================================================
          // PERCENTAGE
          // ============================================================

          Text(
            percentage,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // ============================================================
          // CHART
          // ============================================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: CustomPaint(
              painter: _ChartPainter(
                color: color,
                positive: isPositive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  final bool positive;

  const _ChartPainter({
    required this.color,
    required this.positive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (positive) {
      path.moveTo(0, size.height * 0.48);
      path.lineTo(size.width * 0.10, size.height * 0.62);
      path.lineTo(size.width * 0.20, size.height * 0.35);
      path.lineTo(size.width * 0.32, size.height * 0.80);
      path.lineTo(size.width * 0.43, size.height * 0.50);
      path.lineTo(size.width * 0.58, size.height * 0.62);
      path.lineTo(size.width * 0.70, size.height * 0.42);
      path.lineTo(size.width * 0.82, size.height * 0.18);
      path.lineTo(size.width, size.height * 0.42);
    } else {
      path.moveTo(0, size.height * 0.30);
      path.lineTo(size.width * 0.13, size.height * 0.55);
      path.lineTo(size.width * 0.25, size.height * 0.45);
      path.lineTo(size.width * 0.39, size.height * 0.88);
      path.lineTo(size.width * 0.51, size.height * 0.48);
      path.lineTo(size.width * 0.64, size.height * 0.72);
      path.lineTo(size.width * 0.78, size.height * 0.18);
      path.lineTo(size.width, size.height * 0.62);
    }

    canvas.drawPath(path, linePaint);

    // ================================================================
    // CHART FILL
    // ================================================================

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.13),
          color.withOpacity(0.015),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.positive != positive;
  }
}