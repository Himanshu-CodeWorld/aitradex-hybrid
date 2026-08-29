import 'dart:math';

import 'package:flutter/material.dart';

class FreeCommissionWidget extends StatefulWidget {
  const FreeCommissionWidget({super.key});

  @override
  State<FreeCommissionWidget> createState() =>
      _FreeCommissionWidgetState();
}

class _FreeCommissionWidgetState
    extends State<FreeCommissionWidget>
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

        builder: (_, __) {

          final walletOffset =
              sin(_controller.value * pi) * 10;

          return Stack(
            alignment: Alignment.center,

            children: [

              //--------------------------------
              // BACKGROUND
              //--------------------------------

              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffF3FFF9),
                  border: Border.all(
                    color: const Color(0xffDCF8ED),
                  ),
                ),
              ),

              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xffEAFBF5),
                  ),
                ),
              ),

              Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff23C98D).withOpacity(.05),
                  ),
                ),
              ),

              Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff23C98D).withOpacity(.03),
                  ),
                ),
              ),

              //--------------------------------
              // WALLET
              //--------------------------------

              Transform.translate(
                offset: Offset(
                  0,
                  walletOffset,
                ),
                child: _wallet(),
              ),

              //--------------------------------
              // ZERO BADGE
              //--------------------------------

              Positioned(
                top: 45,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 5,
                  ),
                  child: _zeroBadge(),
                ),
              ),

              //--------------------------------
              // COINS
              //--------------------------------

              _coin(
                left: 40,
                top: 100,
              ),

              _coin(
                right: 45,
                top: 160,
              ),

              _coin(
                left: 70,
                bottom: 55,
              ),

              //--------------------------------
              // DOTS
              //--------------------------------

              const Positioned(
                left: 25,
                top: 40,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),

              const Positioned(
                right: 30,
                bottom: 70,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _wallet() {

    return Container(
      width: 170,
      height: 120,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff39E29D),
            Color(0xff18B67C),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.40),
            blurRadius: 25,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.25),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),

      child: Stack(

        children: [

          Positioned(
            left: 25,
            top: 35,
            child: Container(
              width: 120,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius:
                BorderRadius.circular(18),
              ),
            ),
          ),

          const Center(
            child: Icon(
              Icons.account_balance_wallet,
              size: 56,
              color: Colors.white,
            ),
          ),

          //--------------------------------
          // CREDIT CARD
          //--------------------------------

          Positioned(
            left: 30,
            bottom: 55,
            child: Transform.translate(
              offset: Offset(
                0,
                sin(_controller.value * 2 * pi) * 6,
              ),
              child: _creditCard(),
            ),
          ),

          //--------------------------------
          // PROFIT CARD
          //--------------------------------

          Positioned(
            right: 30,
            top: 110,
            child: Transform.translate(
              offset: Offset(
                0,
                cos(_controller.value * 2 * pi) * 6,
              ),
              child: _profitCard(),
            ),
          ),

          Positioned(
            bottom: 18,
            child: Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.05),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zeroBadge() {

    return Container(
      width: 90,
      height: 90,

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
          "0%",
          style: TextStyle(
            color: Color(0xff23C98D),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
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
        width: 44,
        height: 44,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 15,
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

  Widget _creditCard() {
    return Container(
      width: 95,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff23C98D),
            Color(0xff18B67C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.30),
            blurRadius: 18,
          ),
        ],
      ),
      child: Stack(
        children: [

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 22,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const Positioned(
            bottom: 10,
            left: 12,
            child: Text(
              "AiTradeX",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),

          //--------------------------------
          // FREE BADGE
          //--------------------------------

          Positioned(
            right: 50,
            bottom: 55,
            child: Transform.rotate(
              angle: -.2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff23C98D),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "FREE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          //--------------------------------
          // FLYING COINS
          //--------------------------------

          ...List.generate(5, (index) {

            final angle =
                (_controller.value * 2 * pi) +
                    (index * pi / 2.5);

            return Positioned(
              left: 180 + 110 * cos(angle),
              top: 170 + 110 * sin(angle),

              child: Transform.scale(
                scale: .8 +
                    .2 *
                        sin(angle).abs(),

                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xff23C98D),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "\$",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          //--------------------------------
          // PARTICLES
          //--------------------------------

          ...List.generate(10, (index) {

            final angle = index * (2 * pi / 10);

            return Positioned(
              left: 180 + 145 * cos(angle),
              top: 170 + 145 * sin(angle),
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
          // ORBITING COINS
          //--------------------------------

          ...List.generate(6, (index) {
            final angle =
                (_controller.value * 2 * pi) +
                    (index * (2 * pi / 6));

            const radius = 135.0;

            return Positioned(
              left: 180 + radius * cos(angle) - 16,
              top: 170 + radius * sin(angle) - 16,
              child: Transform.scale(
                scale: .85 + (.15 * sin(angle).abs()),
                child: _orbitCoin(),
              ),
            );
          }),

          //--------------------------------
          // CASH NOTES
          //--------------------------------

          Positioned(
            left: 45,
            top: 80,
            child: Transform.rotate(
              angle: -.25,
              child: _cashNote(),
            ),
          ),

          Positioned(
            right: 45,
            bottom: 95,
            child: Transform.rotate(
              angle: .25,
              child: _cashNote(),
            ),
          ),

          //--------------------------------
          // SPARKLES
          //--------------------------------

          ...List.generate(12, (index) {

            final angle = index * (2 * pi / 12);

            return Positioned(
              left: 180 + 155 * cos(angle),
              top: 170 + 155 * sin(angle),
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
        ],
      ),
    );
  }

  Widget _profitCard() {
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
            "Today's Profit",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "+₹2,540",
            style: TextStyle(
              color: Color(0xff23C98D),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xffF3FFF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: ProfitGraphPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbitCoin() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xff23C98D),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "\$",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _cashNote() {
    return Container(
      width: 58,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xffD8FFE9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xff23C98D),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.attach_money,
          color: Color(0xff23C98D),
          size: 20,
        ),
      ),
    );
  }
}

class ProfitGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = const Color(0xff23C98D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(0, size.height * .8);
    path.lineTo(size.width * .2, size.height * .7);
    path.lineTo(size.width * .4, size.height * .6);
    path.lineTo(size.width * .6, size.height * .4);
    path.lineTo(size.width * .8, size.height * .45);
    path.lineTo(size.width, size.height * .2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}