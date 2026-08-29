import 'dart:math';

import 'package:flutter/material.dart';

class SecurityWidget extends StatefulWidget {
  const SecurityWidget({super.key});

  @override
  State<SecurityWidget> createState() => _SecurityWidgetState();
}

class _SecurityWidgetState extends State<SecurityWidget>
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

          final phoneOffset =
              sin(_controller.value * pi) * 10;

          return Stack(
            alignment: Alignment.center,

            children: [

              //--------------------------------
              // BACKGROUND RINGS
              //--------------------------------

              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffF1FFF8),
                  border: Border.all(
                    color: const Color(0xffD8F8EA),
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
                    color: const Color(0xffE8FFF4),
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
              // PHONE
              //--------------------------------

              Transform.translate(
                offset: Offset(0, phoneOffset),
                child: _phone(),
              ),

              Positioned(
                top: 52,
                child: Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xff23C98D)
                            .withOpacity(.20),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              //--------------------------------
              // SHIELD
              //--------------------------------

              Positioned(
                top: 55,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 6,
                  ),
                  child: _shield(),
                ),
              ),

              //--------------------------------
              // LOCKS
              //--------------------------------

              _lock(
                left: 40,
                top: 100,
              ),

              _lock(
                right: 45,
                top: 160,
              ),

              _lock(
                left: 70,
                bottom: 70,
              ),

              //--------------------------------
              // DOTS
              //--------------------------------

              const Positioned(
                left: 30,
                top: 40,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),

              const Positioned(
                right: 35,
                bottom: 60,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Color(0xff23C98D),
                ),
              ),

              //--------------------------------
              // FACE ID CARD
              //--------------------------------

              Positioned(
                right: 38,
                top: 90,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin(_controller.value * 2 * pi) * 6,
                  ),
                  child: _faceIdCard(),
                ),
              ),

              //--------------------------------
              // AI SECURITY CARD
              //--------------------------------

              Positioned(
                left: 35,
                bottom: 55,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    cos(_controller.value * 2 * pi) * 6,
                  ),
                  child: _aiSecurityCard(),
                ),
              ),

              //--------------------------------
              // SECURITY WAVES
              //--------------------------------

              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {

                    final scale =
                        1 + (.05 * sin(_controller.value * 2 * pi));

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xff23C98D)
                                .withOpacity(.12),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              //--------------------------------
              // FLOATING PARTICLES
              //--------------------------------

              ...List.generate(12, (index) {

                final angle =
                    index * (2 * pi / 12);

                return Positioned(
                  left: 180 + 145 * cos(angle),
                  top: 165 + 145 * sin(angle),

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
                        color: Color(0xff23C98D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              //--------------------------------
              // ORBITING SECURITY ICONS
              //--------------------------------

              ...List.generate(6, (index) {
                final angle =
                    (_controller.value * 2 * pi) +
                        (index * (2 * pi / 6));

                const radius = 130.0;

                final icons = [
                  Icons.lock,
                  Icons.shield,
                  Icons.fingerprint,
                  Icons.verified_user,
                  Icons.security,
                  Icons.key,
                ];

                return Positioned(
                  left: 180 + radius * cos(angle) - 18,
                  top: 165 + radius * sin(angle) - 18,
                  child: Transform.scale(
                    scale: .85 + (.15 * sin(angle).abs()),
                    child: _orbitIcon(
                      icons[index],
                    ),
                  ),
                );
              }),

              Positioned(
                top: 52,
                child: Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xff23C98D)
                            .withOpacity(.20),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 28,
                bottom: 40,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    sin(_controller.value * 2 * pi) * 5,
                  ),
                  child: _statusCard(),
                ),
              ),

              ...List.generate(10, (index) {

                final angle = index * (2 * pi / 10);

                return Positioned(
                  left: 180 + 155 * cos(angle),
                  top: 165 + 155 * sin(angle),
                  child: Opacity(
                    opacity: .4 +
                        .6 *
                            sin(
                              (_controller.value * 2 * pi) + angle,
                            ).abs(),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xff23C98D),
                      size: 12,
                    ),
                  ),
                );
              }),

              Positioned(
                bottom: 18,
                child: Container(
                  width: 170,
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
    );
  }

  Widget _phone() {

    return Container(
      width: 155,
      height: 280,

      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 25,
          ),
        ],
      ),

      padding: const EdgeInsets.all(8),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(

          children: [

            const SizedBox(height: 18),

            Container(
              width: 70,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const Spacer(),

            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {

                final scale =
                    .9 + (.1 * sin(_controller.value * 2 * pi));

                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.fingerprint,
                    size: 70,
                    color: Colors.green.shade400,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _shield() {

    return Container(
      width: 72,
      height: 72,

      decoration: BoxDecoration(
        color: const Color(0xff23C98D),
        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(
            color: const Color(0xff23C98D)
                .withOpacity(.35),
            blurRadius: 20,
          ),
        ],
      ),

      child: const Icon(
        Icons.shield,
        color: Colors.white,
        size: 42,
      ),
    );
  }

  Widget _lock({
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
        width: 42,
        height: 42,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 15,
            ),
          ],
        ),

        child: const Icon(
          Icons.lock,
          color: Color(0xff23C98D),
        ),
      ),
    );
  }

  Widget _faceIdCard() {
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
        Icons.face_unlock_outlined,
        color: Color(0xff23C98D),
        size: 34,
      ),
    );
  }

  Widget _aiSecurityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.auto_awesome,
            color: Color(0xff23C98D),
            size: 18,
          ),

          SizedBox(width: 6),

          Text(
            "AI Secure",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff23C98D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbitIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
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
        icon,
        color: const Color(0xff23C98D),
        size: 18,
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [

          Text(
            "Security",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6),

          Row(
            children: [

              Icon(
                Icons.check_circle,
                color: Color(0xff23C98D),
                size: 18,
              ),

              SizedBox(width: 5),

              Text(
                "Protected",
                style: TextStyle(
                  color: Color(0xff23C98D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}