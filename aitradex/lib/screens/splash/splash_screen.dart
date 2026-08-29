import 'dart:math';
import 'package:get/get.dart';
import 'package:aitradex/screens/home/dashboard_screen.dart';
import 'package:aitradex/services/shared_preferences_service.dart';
import 'package:aitradex/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );


    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoController.forward();
    _navigate();
  }

  @override
  void dispose() {
    // Show status bar again
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _logoController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Show status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    final bool loggedIn =
    await SharedPreferencesService.isLoggedIn();

    final String? token =
    await SharedPreferencesService.getToken();

    if (loggedIn && token != null && token.isNotEmpty) {
      Get.offAll(() => const DashboardScreen());
    } else {
      await SharedPreferencesService.logout();

      Get.offAll(() => const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
          child: Column(
            children: [
              const Spacer(),

              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 45),
                child: BubbleLoader(),
              ),
            ],
          ),
        ),
    );
  }
}

class BubbleLoader extends StatefulWidget {
  const BubbleLoader({super.key});

  @override
  State<BubbleLoader> createState() => _BubbleLoaderState();
}

class _BubbleLoaderState extends State<BubbleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(8, (index) {
                final angle = (2 * pi / 8) * index;

                const radius = 14.0;

                final progress =
                (_controller.value * 8 - index).abs().clamp(0.0, 1.0);

                final size = 5 + (1 - progress) * 5;

                return Transform.translate(
                  offset: Offset(
                    cos(angle) * radius,
                    sin(angle) * radius,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        const Color(0xffF97A63), // Light orange-red
                        const Color(0xffF92902), // Your primary color
                        index / 7,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}