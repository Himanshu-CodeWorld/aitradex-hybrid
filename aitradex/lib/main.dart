import 'dart:async';

import 'package:aitradex/screens/auth/signup/signup_controller.dart';
import 'package:aitradex/screens/auth/captcha/captcha_controller.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen(
          (Uri uri) async {
        if (uri.scheme != "aitradex" ||
            uri.host != "captcha-success") {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            // Reset captcha state
            if (Get.isRegistered<CaptchaController>()) {
              Get.find<CaptchaController>().onCaptchaVerified();
            }

            // Continue signup flow
            if (Get.isRegistered<SignupController>()) {
              final signupController =
              Get.find<SignupController>();

              // Close CaptchaScreen if it is open
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              }

              // Wait until the route pop animation finishes
              await Future.delayed(
                const Duration(milliseconds: 200),
              );

              // Move to NamePage inside PageView
              if (signupController.pageController.hasClients) {
                await signupController.nextPage();
              }
            }
          } catch (e, stackTrace) {
            debugPrint("Deep Link Navigation Error: $e");
            debugPrint(stackTrace.toString());
          }
        });
      },
      onError: (error) {
        debugPrint("Deep Link Error: $error");
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AiTradeX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      home: const SplashScreen(),
    );
  }
}