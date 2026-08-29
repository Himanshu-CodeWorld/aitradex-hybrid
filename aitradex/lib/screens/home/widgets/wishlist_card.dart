import 'package:flutter/material.dart';

class WishlistCard extends StatelessWidget {
  final String symbol;
  final String percent;
  final bool isPositive;
  final IconData icon;

  const WishlistCard({
    super.key,
    required this.symbol,
    required this.percent,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isPositive
        ? const Color(0xff18C48F)
        : const Color(0xffF44336);

    return Container(
      width: 150,
      height: 138,
      padding: const EdgeInsets.fromLTRB(
        13,
        14,
        13,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffEEEEEE),
        ),
      ),
      child: Column(
        children: [
          // ============================================================
          // LOGO + SYMBOL
          // ============================================================

          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ============================================================
          // PERCENTAGE
          // ============================================================

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.add
                      : Icons.remove,
                  size: 12,
                  color: color,
                ),
                Text(
                  percent.replaceAll('+', '').replaceAll('-', ''),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ============================================================
          // CHART
          // ============================================================

          SizedBox(
            height: 42,
            width: double.infinity,
            child: CustomPaint(
              painter: _WishlistChartPainter(
                color,
                isPositive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistChartPainter extends CustomPainter {
  final Color color;
  final bool isPositive;

  const _WishlistChartPainter(
      this.color,
      this.isPositive,
      );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (isPositive) {
      path.moveTo(0, size.height * 0.65);
      path.lineTo(size.width * 0.10, size.height * 0.40);
      path.lineTo(size.width * 0.20, size.height * 0.70);
      path.lineTo(size.width * 0.32, size.height * 0.50);
      path.lineTo(size.width * 0.44, size.height * 0.62);
      path.lineTo(size.width * 0.58, size.height * 0.36);
      path.lineTo(size.width * 0.70, size.height * 0.48);
      path.lineTo(size.width * 0.82, size.height * 0.20);
      path.lineTo(size.width, size.height * 0.38);
    } else {
      path.moveTo(0, size.height * 0.22);
      path.lineTo(size.width * 0.10, size.height * 0.60);
      path.lineTo(size.width * 0.20, size.height * 0.45);
      path.lineTo(size.width * 0.32, size.height * 0.72);
      path.lineTo(size.width * 0.44, size.height * 0.40);
      path.lineTo(size.width * 0.58, size.height * 0.66);
      path.lineTo(size.width * 0.72, size.height * 0.30);
      path.lineTo(size.width * 0.84, size.height * 0.72);
      path.lineTo(size.width, size.height * 0.48);
    }

    canvas.drawPath(path, stroke);

    // ================================================================
    // CHART FILL
    // ================================================================

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.12),
          color.withOpacity(0.01),
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

    canvas.drawPath(fillPath, fill);
  }

  @override
  bool shouldRepaint(
      covariant _WishlistChartPainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.isPositive != isPositive;
  }
}