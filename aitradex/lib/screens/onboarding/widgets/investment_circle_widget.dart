import 'dart:math';

import 'package:flutter/material.dart';

class InvestmentCircleWidget extends StatefulWidget {
  const InvestmentCircleWidget({super.key});

  @override
  State<InvestmentCircleWidget> createState() =>
      _InvestmentCircleWidgetState();
}

class _InvestmentCircleWidgetState
    extends State<InvestmentCircleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 360,
              height: 360,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [

                      //-------------------------
                      // OUTER RING
                      //-------------------------

                      Transform.rotate(
                        angle: controller.value * 2 * pi,
                        child: const OrbitRing(
                          radius: 130,
                          strokeWidth: 8,
                          color: Color(0xff20C997),
                        ),
                      ),

                      //-------------------------
                      // MIDDLE RING
                      //-------------------------

                      Transform.rotate(
                        angle: -controller.value * 2 * pi,
                        child: const OrbitRing(
                          radius: 90,
                          strokeWidth: 6,
                          color: Color(0xff72DFC2),
                        ),
                      ),

                      //-------------------------
                      // CENTER
                      //-------------------------

                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xff20C997),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bubble_chart,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const Positioned(
                        left: 40,
                        top: 60,
                        child: StockLogo(
                          image: "assets/logos/apple.png",
                          percent: "+10.57%",
                        ),
                      ),

                      const Positioned(
                        right: 35,
                        top: 35,
                        child: StockLogo(
                          image: "assets/logos/tesla.png",
                          percent: "+8.29%",
                        ),
                      ),

                      const Positioned(
                        right: 25,
                        bottom: 40,
                        child: StockLogo(
                          image: "assets/logos/google.png",
                          percent: "+9.56%",
                        ),
                      ),

                      const Positioned(
                        left: 70,
                        bottom: 20,
                        child: StockLogo(
                          image: "assets/logos/facebook.png",
                          percent: "+6.42%",
                        ),
                      ),

                      const Positioned(
                        bottom: 60,
                        child: StockLogo(
                          image: "assets/logos/netflix.png",
                          percent: "+8.74%",
                        ),
                      ),

                      const Positioned(
                        top: 90,
                        child: StockLogo(
                          image: "assets/logos/spotify.png",
                          percent: "+9.93%",
                        ),
                      ),

                      const Positioned(
                        left: 90,
                        bottom: 100,
                        child: StockLogo(
                          image: "assets/logos/mcdonald.png",
                          percent: "+5.38%",
                        ),
                      ),

                      const Positioned(
                        right: 85,
                        top: 110,
                        child: StockLogo(
                          image: "assets/logos/figma.png",
                          percent: "+7.44%",
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrbitRing extends StatelessWidget {
  final double radius;
  final double strokeWidth;
  final Color color;

  const OrbitRing({
    super.key,
    required this.radius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: OrbitPainter(
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  const OrbitPainter({
    required this.strokeWidth,
    required this.color,
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const gap = pi / 6;

    for (double i = 0; i < 2 * pi; i += gap * 2) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        i,
        gap,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StockLogo extends StatelessWidget {
  final String image;
  final String percent;

  const StockLogo({
    super.key,
    required this.image,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.business,
                  size: 18,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}