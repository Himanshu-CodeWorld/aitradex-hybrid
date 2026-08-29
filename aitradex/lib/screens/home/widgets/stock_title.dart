import 'package:flutter/material.dart';

class StockTile extends StatelessWidget {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final bool isPositive;
  final IconData icon;

  const StockTile({
    super.key,
    required this.company,
    required this.symbol,
    required this.price,
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
      height: 76,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ============================================================
          // LOGO
          // ============================================================

          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 29,
            ),
          ),

          const SizedBox(width: 15),

          // ============================================================
          // COMPANY NAME
          // ============================================================

          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ============================================================
          // SPARKLINE
          // ============================================================

          SizedBox(
            width: 72,
            height: 36,
            child: CustomPaint(
              painter: _SparkLinePainter(
                color: color,
                positive: isPositive,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ============================================================
          // PRICE
          // ============================================================

          SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  percent,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  final Color color;
  final bool positive;

  const _SparkLinePainter({
    required this.color,
    required this.positive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final line = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (positive) {
      path.moveTo(0, size.height * 0.55);
      path.lineTo(size.width * 0.08, size.height * 0.35);
      path.lineTo(size.width * 0.16, size.height * 0.62);
      path.lineTo(size.width * 0.24, size.height * 0.42);
      path.lineTo(size.width * 0.34, size.height * 0.58);
      path.lineTo(size.width * 0.43, size.height * 0.48);
      path.lineTo(size.width * 0.52, size.height * 0.62);
      path.lineTo(size.width * 0.62, size.height * 0.30);
      path.lineTo(size.width * 0.72, size.height * 0.45);
      path.lineTo(size.width * 0.82, size.height * 0.18);
      path.lineTo(size.width * 0.92, size.height * 0.28);
      path.lineTo(size.width, size.height * 0.12);
    } else {
      path.moveTo(0, size.height * 0.28);
      path.lineTo(size.width * 0.10, size.height * 0.48);
      path.lineTo(size.width * 0.20, size.height * 0.38);
      path.lineTo(size.width * 0.30, size.height * 0.65);
      path.lineTo(size.width * 0.40, size.height * 0.50);
      path.lineTo(size.width * 0.50, size.height * 0.72);
      path.lineTo(size.width * 0.60, size.height * 0.42);
      path.lineTo(size.width * 0.70, size.height * 0.65);
      path.lineTo(size.width * 0.80, size.height * 0.52);
      path.lineTo(size.width * 0.90, size.height * 0.75);
      path.lineTo(size.width, size.height * 0.60);
    }

    canvas.drawPath(path, line);

    // ================================================================
    // CHART FILL
    // ================================================================

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.14),
          color.withOpacity(0.0),
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
      covariant _SparkLinePainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.positive != positive;
  }
}