
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:aitradex/screens/onboarding/onboarding_screen.dart';
import 'package:aitradex/services/shared_preferences_service.dart';

/// AiTradeX Splash Screen.
///
/// Responsibilities:
/// - Shows the branded splash animation.
/// - Restores the Firebase authentication session.
/// - Validates that the Firebase account still exists.
/// - Restores the local user cache.
/// - Redirects authenticated users to `/bottom-nav`.
/// - Redirects unauthenticated users to onboarding.
/// - Supports Light Mode, Dark Mode and App Theme colors.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _hideSystemUI();
    _initializeAnimation();
    _startNavigation();
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  void _showSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  // ============================================================
  // LOGO ANIMATION
  // ============================================================

  void _initializeAnimation() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoController.forward();
  }

  // ============================================================
  // START NAVIGATION
  // ============================================================

  Future<void> _startNavigation() async {
    if (_navigationStarted) {
      return;
    }

    _navigationStarted = true;

    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) {
      return;
    }

    await _checkAuthentication();
  }

  // ============================================================
  // AUTHENTICATION CHECK
  // ============================================================

  Future<void> _checkAuthentication() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      debugPrint('');
      debugPrint('========================================');
      debugPrint('AiTradeX SPLASH AUTH CHECK');
      debugPrint('Firebase UID: ${user?.uid ?? "NULL"}');
      debugPrint('Email: ${user?.email ?? "NULL"}');
      debugPrint('Email verified: ${user?.emailVerified ?? false}');
      debugPrint('========================================');

      if (user == null) {
        await SharedPreferencesService.clearAuthenticatedUserData();
        if (!mounted) return;
        _navigateToOnboarding();
        return;
      }

      // Refresh Firebase first. Firebase is the source of truth for
      // authentication; a temporary API/Mongo failure must not log out
      // an otherwise valid Firebase session.
      try {
        await user.reload();
        user = auth.currentUser;
      } on FirebaseAuthException catch (error) {
        debugPrint(
          'Firebase reload failed: ${error.code} - ${error.message}',
        );

        final bool accountInvalid =
            error.code == 'user-not-found' ||
                error.code == 'user-disabled' ||
                error.code == 'user-token-expired' ||
                error.code == 'invalid-user-token';

        if (accountInvalid) {
          try {
            await auth.signOut();
          } catch (signOutError) {
            debugPrint('Firebase sign-out error: $signOutError');
          }

          await SharedPreferencesService.clearAuthenticatedUserData();
          if (!mounted) return;
          _navigateToOnboarding();
          return;
        }
      }

      user = auth.currentUser;

      if (user == null) {
        await SharedPreferencesService.clearAuthenticatedUserData();
        if (!mounted) return;
        _navigateToOnboarding();
        return;
      }

      await _restoreUserSession(user);

      if (!mounted) return;

      _showSystemUI();

      // AppLockGate is attached to /bottom-nav. If App Lock is enabled,
      // it will immediately show the 4-digit MPIN screen.
      Get.offAllNamed('/bottom-nav');
    } catch (error, stackTrace) {
      debugPrint('========================================');
      debugPrint('SPLASH AUTH ERROR');
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      _showSystemUI();
      await SharedPreferencesService.clearAuthenticatedUserData();
      _navigateToOnboarding();
    }
  }

  // ============================================================
  // RESTORE USER SESSION
  // ============================================================

  Future<void> _restoreUserSession(
      User user,
      ) async {
    try {
      final String uid = user.uid;

      final String name =
          user.displayName?.trim() ?? '';

      final String email =
          user.email?.trim() ?? '';

      final String profileImageUrl =
          user.photoURL?.trim() ?? '';

      // --------------------------------------------------------
      // RESTORE LOGIN STATE
      // --------------------------------------------------------

      await SharedPreferencesService.login(
        userId: uid,
        name: name,
        email: email,
        emailVerified: user.emailVerified,
        profileImageUrl: profileImageUrl,
      );

      // --------------------------------------------------------
      // SAVE FIREBASE UID
      // --------------------------------------------------------

      await SharedPreferencesService.saveFirebaseUid(
        uid,
      );

      // --------------------------------------------------------
      // RESTORE PROFILE CACHE
      // --------------------------------------------------------

      await SharedPreferencesService.saveUserProfile(
        name: name,
        email: email,
        emailVerified: user.emailVerified,
        profileImageUrl: profileImageUrl,
      );

      debugPrint(
        'Local user session restored successfully.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'RESTORE USER SESSION ERROR: $error',
      );

      debugPrint(
        stackTrace.toString(),
      );

      // Firebase is still the authentication source
      // of truth. A local cache error should not force
      // a valid Firebase user back to onboarding.
    }
  }

  // ============================================================
  // ONBOARDING NAVIGATION
  // ============================================================

  void _navigateToOnboarding() {
    if (!mounted) {
      return;
    }

    _showSystemUI();

    Get.offAll(
          () => const OnboardingScreen(),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _showSystemUI();

    _logoController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color backgroundColor =
        theme.scaffoldBackgroundColor;

    final Color primaryColor =
        theme.colorScheme.primary;

    final Color secondaryColor =
        theme.colorScheme.secondary;

    final Color onSurfaceColor =
        theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND GLOW
            // ==================================================

            Positioned(
              top: -150,
              right: -120,
              child: _GlowCircle(
                size: 360,
                color: primaryColor,
                opacity: 0.07,
              ),
            ),

            Positioned(
              bottom: -180,
              left: -140,
              child: _GlowCircle(
                size: 380,
                color: secondaryColor,
                opacity: 0.045,
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Column(
              children: [
                const Spacer(
                  flex: 3,
                ),

                // ------------------------------------------------
                // LOGO
                // ------------------------------------------------

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: _SplashLogo(
                        primaryColor: primaryColor,
                      ),
                    ),
                  ),
                ),

                const Spacer(
                  flex: 3,
                ),

                // ------------------------------------------------
                // LOADER
                // ------------------------------------------------

                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 44,
                  ),
                  child: BubbleLoader(),
                ),
              ],
            ),

            // ==================================================
            // BRAND LABEL
            // ==================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: IgnorePointer(
                child: Text(
                  'AiTradeX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: onSurfaceColor.withValues(
                      alpha: 0.28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SPLASH LOGO
// ==================================================================

class _SplashLogo extends StatelessWidget {
  final Color primaryColor;

  const _SplashLogo({
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fallbackColor =
        Theme.of(context).colorScheme.onSurface;

    return Image.asset(
      'assets/images/logo.png',
      width: 300,
      fit: BoxFit.contain,
      errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
          ) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(
              alpha: 0.10,
            ),
            border: Border.all(
              color: primaryColor.withValues(
                alpha: 0.22,
              ),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.trending_up_rounded,
            size: 58,
            color: primaryColor,
          ),
        );
      },
    );
  }
}

// ==================================================================
// GLOW CIRCLE
// ==================================================================

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(
            alpha: opacity,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// BUBBLE LOADER
// ==================================================================

class BubbleLoader extends StatefulWidget {
  const BubbleLoader({super.key});

  @override
  State<BubbleLoader> createState() =>
      _BubbleLoaderState();
}

class _BubbleLoaderState extends State<BubbleLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 52,
      height: 52,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (
            BuildContext context,
            Widget? child,
            ) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(
              8,
                  (int index) {
                final double angle =
                    (2 * pi / 8) * index;

                const double radius = 15.0;

                final double rawProgress =
                    (_controller.value * 8 - index) % 8;

                final double distance =
                rawProgress > 4
                    ? 8 - rawProgress
                    : rawProgress;

                final double progress =
                (distance / 4).clamp(
                  0.0,
                  1.0,
                );

                final double size =
                    5.0 +
                        (1.0 - progress) * 5.0;

                final Color bubbleColor =
                    Color.lerp(
                      primaryColor.withValues(
                        alpha: 0.35,
                      ),
                      primaryColor,
                      1.0 - progress,
                    ) ??
                        primaryColor;

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
                      color: bubbleColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                          primaryColor.withValues(
                            alpha: 0.14,
                          ),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}