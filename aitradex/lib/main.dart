import 'package:aitradex/core/theme/app_theme.dart';
import 'package:aitradex/core/theme/theme_controller.dart';
import 'package:aitradex/firebase_options.dart';
import 'package:aitradex/screens/account/app_lock_gate.dart';
import 'package:aitradex/screens/auth/signin/signin_screen.dart';
import 'package:aitradex/screens/bottomNavigation/bottom_nav.dart';
import 'package:aitradex/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before starting the application.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('AiTradeX: Firebase initialized successfully.');
  } catch (error, stackTrace) {
    debugPrint('AiTradeX: Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    return;
  }

  // Register the global theme controller.
  if (!Get.isRegistered<ThemeController>()) {
    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );
  }

  // MarketDataController registration is intentionally omitted.
  // Dashboard market data is fetched through the existing market-data service.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
    Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'AiTradeX',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme(
        themeController.primaryColor.value,
      ),

      darkTheme: AppTheme.darkTheme(
        themeController.primaryColor.value,
      ),

      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,

      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      home: const SplashScreen(),

      getPages: [
        GetPage(
          name: '/login',
          page: () => const SignInScreen(),
          transition: Transition.fadeIn,
          transitionDuration:
          const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/bottom-nav',
          page: () => const AppLockGate(
            child: BottomNav(),
          ),
          transition: Transition.fadeIn,
          transitionDuration:
          const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
