import 'dart:math';

import 'package:flutter/material.dart';

class OneDollarWidget extends StatefulWidget {
  const OneDollarWidget({super.key});

  @override
  State<OneDollarWidget> createState() => _OneDollarWidgetState();
}

class _OneDollarWidgetState extends State<OneDollarWidget>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

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

    return SizedBox(
      height: 360,
      width: double.infinity,

      child: AnimatedBuilder(
        animation: _controller,

        builder: (context, child) {

          final dy = sin(_controller.value * pi) * 12;

          return Stack(
            alignment: Alignment.center,

            children: [

              //------------------------------------------
              // BACKGROUND CIRCLES
              //------------------------------------------

              Positioned(
                top: 25,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffEAFBF5),
                    border: Border.all(
                      color: const Color(0xffD6F6E9),
                      width: 2,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xffDDF7EC),
                    ),
                  ),
                ),
              ),

              //------------------------------------------
              // MAIN $1 COIN
              //------------------------------------------

              Transform.translate(
                offset: Offset(0, dy),

                child: Container(
                  width: 120,
                  height: 120,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff23D18B),
                        Color(0xff12B76A),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff23D18B).withOpacity(.35),
                        blurRadius: 35,
                        spreadRadius: 6,
                      ),
                    ],
                  ),

                  child: const Center(
                    child: Text(
                      "\$1",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
              ),

              //------------------------------------------
              // SMALL COINS
              //------------------------------------------

              _coin(
                left: 35,
                top: 80,
                size: 42,
              ),

              _coin(
                right: 40,
                top: 120,
                size: 30,
              ),

              _coin(
                right: 70,
                bottom: 70,
                size: 36,
              ),

              _coin(
                left: 70,
                bottom: 50,
                size: 28,
              ),

              //------------------------------------------
              // DECORATIVE DOTS
              //------------------------------------------

              const Positioned(
                left: 25,
                top: 40,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xff23D18B),
                ),
              ),

              const Positioned(
                right: 40,
                bottom: 120,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Color(0xff23D18B),
                ),
              ),

              //------------------------------------------
              // AI CHIP
              //------------------------------------------

              Positioned(
                top: 60,
                right: 65,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 8,
                  ),
                  child: _aiChip(),
                ),
              ),

              //------------------------------------------
              // STOCK CARD
              //------------------------------------------

              Positioned(
                bottom: 45,
                left: 35,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin(_controller.value * 2 * pi) * 6,
                  ),
                  child: _stockCard(),
                ),
              ),

              //------------------------------------------
              // LEAF
              //------------------------------------------

              Positioned(
                left: 40,
                top: 150,
                child: Transform.rotate(
                  angle: sin(_controller.value * pi) * .2,
                  child: _leaf(),
                ),
              ),

              Positioned(
                right: 45,
                bottom: 90,
                child: Transform.rotate(
                  angle: -sin(_controller.value * pi) * .2,
                  child: _leaf(),
                ),
              ),

              //------------------------------------------
              // ORBITING COINS
              //------------------------------------------

              ...List.generate(6, (index) {
                final angle = (_controller.value * 2 * pi) + (index * pi / 3);

                final radius = 135.0;

                return Positioned(
                  left: 180 + radius * cos(angle) - 14,
                  top: 165 + radius * sin(angle) - 14,
                  child: Transform.scale(
                    scale: .85 + (.15 * sin(angle)),
                    child: _orbitCoin(),
                  ),
                );
              }),

              //------------------------------------------
              // PARTICLES
              //------------------------------------------

              ...List.generate(14, (i) {

                final angle = i * 25 * pi / 180;

                return Positioned(
                  left: 180 + 150 * cos(angle),
                  top: 165 + 150 * sin(angle),

                  child: Transform.scale(
                    scale: .6 +
                        .4 *
                            sin(
                              (_controller.value * 2 * pi) + angle,
                            ).abs(),

                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xff22C58B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                bottom: 15,
                child: Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black.withOpacity(.05),
                  ),
                ),
              ),

              Positioned(
                right: 60,
                top: 190,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff22C58B),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 15,
                      ),

                      SizedBox(width: 5),

                      Text(
                        "AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                child: IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xff22C58B)
                            .withOpacity(.08),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                child: IgnorePointer(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xff22C58B)
                            .withOpacity(.04),
                      ),
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

  Widget _coin({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
  }) {

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,

      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff23D18B).withOpacity(.15),
        ),

        child: Center(
          child: Container(
            width: size * .55,
            height: size * .55,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff23D18B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leaf() {
    return Container(
      width: 30,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xff22C58B),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _aiChip() {
    return Container(
      width: 62,
      height: 62,
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
      child: const Icon(
        Icons.psychology,
        color: Color(0xff22C58B),
        size: 34,
      ),
    );
  }

  Widget _stockCard() {
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

          const Text(
            "AAPL",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            height: 36,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffECFFF7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: GraphPainter(),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "+12.54%",
            style: TextStyle(
              color: Color(0xff22C58B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbitCoin() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff22C58B),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff22C58B).withOpacity(.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "\$",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff22C58B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(0, size.height * .8);

    path.lineTo(size.width * .2, size.height * .6);
    path.lineTo(size.width * .4, size.height * .65);
    path.lineTo(size.width * .6, size.height * .35);
    path.lineTo(size.width * .8, size.height * .45);
    path.lineTo(size.width, size.height * .15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}