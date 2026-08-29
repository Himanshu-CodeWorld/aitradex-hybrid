import 'dart:math';
import 'package:flutter/material.dart';

class RealSharesWidget extends StatefulWidget {
  const RealSharesWidget({super.key});

  @override
  State<RealSharesWidget> createState() => _RealSharesWidgetState();
}

class _RealSharesWidgetState extends State<RealSharesWidget>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                animation: _controller,
                builder: (context, child) {
                  final globeOffset = sin(_controller.value * pi) * 8;

                  return Stack(
                    alignment: Alignment.center,
                    children: [

                      //--------------------------------
                      // BACKGROUND CIRCLES
                      //--------------------------------

                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xffF3FFF9),
                          border: Border.all(
                            color: const Color(0xffDCF8ED),
                          ),
                        ),
                      ),

                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xffEBFBF5),
                          ),
                        ),
                      ),

                      Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xff23C98D).withOpacity(.15),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      IgnorePointer(
                        child: CustomPaint(
                          size: const Size(360, 360),
                          painter: ConnectionPainter(),
                        ),
                      ),

                      //--------------------------------
                      // GLOBE
                      //--------------------------------

                      Transform.translate(
                        offset: Offset(0, globeOffset),
                        child: _globe(),
                      ),

                      //--------------------------------
                      // AI BADGE
                      //--------------------------------

                      Positioned(
                        top: 40,
                        child: _aiBadge(),
                      ),

                      //--------------------------------
                      // BUILDINGS
                      //--------------------------------

                      Positioned(
                        bottom: 40,
                        left: 45,
                        child: _building(55),
                      ),

                      Positioned(
                        bottom: 40,
                        right: 45,
                        child: _building(70),
                      ),

                      //--------------------------------
                      // COMPANY ICONS
                      //--------------------------------

                      _companyIcon(
                        left: 40,
                        top: 95,
                        icon: Icons.business,
                      ),

                      _companyIcon(
                        right: 35,
                        top: 140,
                        icon: Icons.show_chart,
                      ),

                      _companyIcon(
                        left: 70,
                        bottom: 95,
                        icon: Icons.trending_up,
                      ),

                      //--------------------------------
                      // DECORATION
                      //--------------------------------

                      const Positioned(
                        left: 28,
                        top: 40,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xff23C98D),
                        ),
                      ),

                      const Positioned(
                        right: 32,
                        bottom: 60,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xff23C98D),
                        ),
                      ),

                      //--------------------------------
                      // PORTFOLIO CARD
                      //--------------------------------

                      Positioned(
                        right: 28,
                        top: 95,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            sin(_controller.value * 2 * pi) * 6,
                          ),
                          child: _portfolioCard(),
                        ),
                      ),

                      //--------------------------------
                      // STOCK CARD
                      //--------------------------------

                      Positioned(
                        left: 28,
                        bottom: 60,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            cos(_controller.value * 2 * pi) * 6,
                          ),
                          child: _stockCard(),
                        ),
                      ),

                      //--------------------------------
                      // ORBITING COINS
                      //--------------------------------

                      ...List.generate(6, (index) {
                        final angle = (_controller.value * 2 * pi) +
                            index * (2 * pi / 6);

                        const radius = 130.0;

                        return Positioned(
                          left: 180 + radius * cos(angle) - 15,
                          top: 180 + radius * sin(angle) - 15,
                          child: _orbitCoin(),
                        );
                      }),

                      //--------------------------------
                      // BOTTOM SHADOW
                      //--------------------------------

                      Positioned(
                        bottom: 18,
                        child: Container(
                          width: 190,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.05),
                            borderRadius: BorderRadius.circular(50),
                          ),
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

  Widget _globe() {

    return Container(
      width: 170,
      height: 170,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff42F5A7),
            Color(0xff18B67C),
          ],
        ),

        boxShadow: [

          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.40),
            blurRadius: 35,
            spreadRadius: 4,
          ),

          BoxShadow(
            color: Colors.white.withOpacity(.20),
            blurRadius: 20,
          ),
        ],
      ),

      child:  Center(
        child: Stack(
          alignment: Alignment.center,
          children: [

            CustomPaint(
              size: const Size(170, 170),
              painter: GlobeGridPainter(),
            ),

            const Icon(
              Icons.public,
              color: Colors.white,
              size: 78,
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff23C98D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 18,
          ),

          SizedBox(width: 6),

          Text(
            "AI Invest",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _building(double height) {
    return Container(
      width: 42,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(
        Icons.apartment,
        color: Color(0xff23C98D),
      ),
    );
  }

  Widget _portfolioCard() {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [

          Text(
            "Portfolio",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "+18.42%",
            style: TextStyle(
              color: Color(0xff23C98D),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          SizedBox(height: 4),

          Text(
            "This Month",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
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
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Growth",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffF3FFF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: GrowthPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyIcon({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required IconData icon,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xff23C98D),
        ),
      ),
    );
  }

  Widget _orbitCoin() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff23C98D),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff23C98D).withOpacity(.35),
            blurRadius: 10,
          ),
        ],
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
    );
  }

  Widget _marketBadge(
      String text,
      IconData icon,
      ) {
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 16,
            color: const Color(0xff23C98D),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff23C98D),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class GrowthPainter extends CustomPainter {

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
    path.lineTo(size.width * .4, size.height * .55);
    path.lineTo(size.width * .6, size.height * .45);
    path.lineTo(size.width * .8, size.height * .35);
    path.lineTo(size.width, size.height * .15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class GlobeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.white.withOpacity(.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, size.width * .42, paint);

    canvas.drawCircle(center, size.width * .28, paint);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .45,
        height: size.height * .82,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .82,
        height: size.height * .45,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff23C98D).withOpacity(.18)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      const Offset(90, 110),
      const Offset(180, 180),
      paint,
    );

    canvas.drawLine(
      const Offset(270, 120),
      const Offset(180, 180),
      paint,
    );

    canvas.drawLine(
      const Offset(90, 270),
      const Offset(180, 180),
      paint,
    );

    canvas.drawLine(
      const Offset(270, 260),
      const Offset(180, 180),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}