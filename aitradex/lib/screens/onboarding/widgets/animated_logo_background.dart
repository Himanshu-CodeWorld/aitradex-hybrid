import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedLogoBackground extends StatefulWidget {
  const AnimatedLogoBackground({super.key});

  @override
  State<AnimatedLogoBackground> createState() =>
      _AnimatedLogoBackgroundState();
}

class _AnimatedLogoBackgroundState
    extends State<AnimatedLogoBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<_LogoData> logos = const [
    _LogoData(
      image: "assets/logos/spotify.png",
      left: .02,
      top: .03,
      phase: 0,
    ),
    _LogoData(
      image: "assets/logos/tesla.png",
      left: .28,
      top: .01,
      phase: .4,
    ),
    _LogoData(
      image: "assets/logos/apple.png",
      left: .54,
      top: .03,
      phase: .8,
    ),
    _LogoData(
      image: "assets/logos/intel.png",
      left: .80,
      top: .01,
      phase: 1.2,
    ),
    _LogoData(
      image: "assets/logos/facebook.png",
      left: .00,
      top: .32,
      phase: .3,
    ),
    _LogoData(
      image: "assets/logos/netflix.png",
      left: .27,
      top: .29,
      phase: .7,
    ),
    _LogoData(
      image: "assets/logos/dell.png",
      left: .54,
      top: .32,
      phase: 1.1,
    ),
    _LogoData(
      image: "assets/logos/figma.png",
      left: .81,
      top: .29,
      phase: 1.6,
    ),
    _LogoData(
      image: "assets/logos/cocacola.png",
      left: .03,
      top: .63,
      phase: .5,
    ),
    _LogoData(
      image: "assets/logos/google.png",
      left: .29,
      top: .60,
      phase: .9,
    ),
    _LogoData(
      image: "assets/logos/mcdonald.png",
      left: .55,
      top: .63,
      phase: 1.4,
    ),
    _LogoData(
      image: "assets/logos/slack.png",
      left: .81,
      top: .60,
      phase: 1.9,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = width * .92;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              ...logos.map((logo) {
                final dy =
                    sin((_controller.value * 2 * pi) + logo.phase) * 8;

                final scale =
                    1 +
                        (cos((_controller.value * 2 * pi) + logo.phase) * .04);

                return Positioned(
                  left: width * logo.left,
                  top: height * logo.top + dy,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          logo.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              //--------------------------------
              // Bottom Fade
              //--------------------------------

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(.55),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.0,
                          .38,
                          1,
                        ],
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
}

class _LogoData {
  final String image;
  final double left;
  final double top;
  final double phase;

  const _LogoData({
    required this.image,
    required this.left,
    required this.top,
    required this.phase,
  });
}