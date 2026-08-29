import 'dart:math';
import 'package:flutter/material.dart';

class NoSpreadWidget extends StatefulWidget {
  const NoSpreadWidget({super.key});

  @override
  State<NoSpreadWidget> createState() =>
      _NoSpreadWidgetState();
}

class _NoSpreadWidgetState
    extends State<NoSpreadWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final phoneY =
        sin(_controller.value * pi) * 10;

    return SizedBox(
      height: 360,
      width: double.infinity,

      child: AnimatedBuilder(
        animation: _controller,

        builder: (_, __) {

          return Stack(
            alignment: Alignment.center,

            children: [

              //----------------------------------
              // BACKGROUND
              //----------------------------------

              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffF4FFF9),
                  border: Border.all(
                    color: const Color(0xffDDF9EE),
                  ),
                ),
              ),

              Container(
                width: 235,
                height: 235,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xffEBFBF5),
                  ),
                ),
              ),

              //--------------------------------
              // EXECUTION RINGS
              //--------------------------------

              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final scale = 1 + (.04 * sin(_controller.value * 2 * pi));

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 270,
                      height: 270,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff23C98D).withOpacity(.10),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),

              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff23C98D).withOpacity(.05),
                  ),
                ),
              ),

              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff23C98D).withOpacity(.03),
                  ),
                ),
              ),

              //----------------------------------
              // PHONE
              //----------------------------------

              Transform.translate(
                offset: Offset(0, phoneY),
                child: _phone(),
              ),

              //----------------------------------
              // ZERO SPREAD
              //----------------------------------

              Positioned(
                top: 45,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 6,
                  ),
                  child: _spreadBadge(),
                ),
              ),

              //----------------------------------
              // BUY CARD
              //----------------------------------

              Positioned(
                left: 30,
                bottom: 60,
                child: _tradeCard(
                  "BUY",
                  Colors.green,
                ),
              ),

              //----------------------------------
              // SELL CARD
              //----------------------------------

              Positioned(
                right: 30,
                top: 130,
                child: _tradeCard(
                  "SELL",
                  Colors.red,
                ),
              ),

              //----------------------------------
              // COINS
              //----------------------------------

              _coin(left: 45, top: 95),
              _coin(right: 50, bottom: 70),

              const Positioned(
                left: 25,
                top: 40,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),

              const Positioned(
                right: 35,
                bottom: 45,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),

              //--------------------------------
              // AI TRADING CARD
              //--------------------------------

              Positioned(
                left: 28,
                top: 120,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin(_controller.value * 2 * pi) * 6,
                  ),
                  child: _aiTradingCard(),
                ),
              ),

              //--------------------------------
              // EXECUTION BADGE
              //--------------------------------

              Positioned(
                right: 25,
                bottom: 60,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 6,
                  ),
                  child: _executionBadge(),
                ),
              ),

              //--------------------------------
              // ORBITING ICONS
              //--------------------------------

              ...List.generate(6, (index) {

                final angle =
                    (_controller.value * 2 * pi) +
                        (index * (2 * pi / 6));

                const radius = 130.0;

                final icons = [
                  Icons.trending_up,
                  Icons.show_chart,
                  Icons.attach_money,
                  Icons.analytics,
                  Icons.candlestick_chart,
                  Icons.currency_exchange,
                ];

                return Positioned(
                  left: 180 + radius * cos(angle) - 16,
                  top: 170 + radius * sin(angle) - 16,
                  child: Transform.scale(
                    scale: .85 +
                        .15 *
                            sin(angle).abs(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        icons[index],
                        color: const Color(0xff23C98D),
                        size: 18,
                      ),
                    ),
                  ),
                );
              }),

              //--------------------------------
              // PARTICLES
              //--------------------------------

              ...List.generate(12, (index) {

                final angle =
                    index * (2 * pi / 12);

                return Positioned(
                  left: 180 + 150 * cos(angle),
                  top: 170 + 150 * sin(angle),
                  child: Opacity(
                    opacity: .4 +
                        .6 *
                            sin(
                              (_controller.value * 2 * pi) + angle,
                            ).abs(),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xff23C98D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              //--------------------------------
              // PRICE TAGS
              //--------------------------------

              Positioned(
                left: 45,
                top: 75,
                child: Transform.rotate(
                  angle: -.18,
                  child: _priceTag("+0.0"),
                ),
              ),

              Positioned(
                right: 40,
                bottom: 95,
                child: Transform.rotate(
                  angle: .18,
                  child: _priceTag("0 Spread"),
                ),
              ),

              //--------------------------------
              // SPARKLES
              //--------------------------------

              ...List.generate(10, (index) {

                final angle = index * (2 * pi / 10);

                return Positioned(
                  left: 180 + 160 * cos(angle),
                  top: 170 + 160 * sin(angle),
                  child: Opacity(
                    opacity: .4 +
                        .6 *
                            sin(
                              (_controller.value * 2 * pi) + angle,
                            ).abs(),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Color(0xff23C98D),
                    ),
                  ),
                );
              }),

              Positioned(
                bottom: 18,
                child: Container(
                  width: 170,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.05),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              Positioned(
                right: 55,
                top: 70,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin(_controller.value * 2 * pi) * 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white,
                        ),

                        SizedBox(width: 5),

                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _phone() {

    return Container(
      width: 150,
      height: 270,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff2F2F2F),
            Color(0xff111111),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.20),
            blurRadius: 22,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 18,
          ),
        ],
      ),

      padding: const EdgeInsets.all(8),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),

        child: Column(
          children: [

            const SizedBox(height: 18),

            Container(
              width: 70,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomPaint(
                  painter: ChartPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spreadBadge() {

    return Container(
      width: 95,
      height: 95,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
          ),
        ],
      ),

      child: const Center(
        child: Text(
          "0.0",
          style: TextStyle(
            color: Color(0xff23C98D),
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
        ),
      ),
    );
  }

  Widget _tradeCard(
      String title,
      Color color,
      ) {

    return Container(
      width: 72,
      height: 48,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),

      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _aiTradingCard() {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.auto_awesome,
                color: Color(0xff23C98D),
                size: 18,
              ),

              SizedBox(width: 5),

              Text(
                "AI Trade",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffF4FFF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: CandlePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _executionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff23C98D),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.30),
            blurRadius: 15,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 16,
          ),

          SizedBox(width: 4),

          Text(
            "Instant",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff23C98D),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _coin({
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,

      child: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
            ),
          ],
        ),

        child: const Icon(
          Icons.attach_money,
          color: Color(0xff23C98D),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = const Color(0xff23C98D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height * .8);
    path.lineTo(size.width * .15, size.height * .65);
    path.lineTo(size.width * .30, size.height * .7);
    path.lineTo(size.width * .45, size.height * .45);
    path.lineTo(size.width * .60, size.height * .55);
    path.lineTo(size.width * .75, size.height * .30);
    path.lineTo(size.width, size.height * .15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CandlePainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    final green = Paint()
      ..color = const Color(0xff23C98D)
      ..strokeWidth = 2;

    final red = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {

      final x = (i + 1) * size.width / 6;

      final top = (i % 2 == 0)
          ? size.height * .25
          : size.height * .45;

      final bottom = size.height * .8;

      final paint = i.isEven ? green : red;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        paint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x - 4,
          top + 10,
          8,
          18,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}