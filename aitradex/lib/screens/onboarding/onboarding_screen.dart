import 'package:aitradex/screens/auth/signin/signin_screen.dart';
import 'package:aitradex/screens/auth/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:aitradex/screens/auth/signup/signup_binding.dart';
import '../auth/google/google_auth_controller.dart';

import '../../models/onboarding_model.dart';
import 'onboarding_page.dart';

// These widgets will be created in the next steps.
import 'widgets/animated_logo_background.dart';
import 'widgets/investment_circle_widget.dart';
import 'widgets/one_dollar_widget.dart';
import 'widgets/security_widget.dart';
import 'widgets/free_commission_widget.dart';
import 'widgets/no_spread_widget.dart';
import 'widgets/real_shares_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  late final GoogleAuthController googleAuthController;

  int currentPage = 0;

  late final List<OnboardingModel> pages;

  @override
  void initState() {
    super.initState();

    googleAuthController =
    Get.isRegistered<GoogleAuthController>()
        ? Get.find<GoogleAuthController>()
        : Get.put(GoogleAuthController());

    pages = [

      //---------------------------------------------------
      // PAGE 1
      //---------------------------------------------------

      const OnboardingModel(
        background: AnimatedLogoBackground(),
        title: "Welcome to AiTradeX",
        emoji: "👋",
        subtitle:
        "The best app to invest in international stocks with as little as \$1.00",
      ),

      //---------------------------------------------------
      // PAGE 2
      //---------------------------------------------------

      const OnboardingModel(
        background: InvestmentCircleWidget(),
        title: "Get Better Returns",
        emoji: "🚀",
        subtitle:
        "Invest in the world's top leading brands & unlock amazing returns of investment.",
      ),

      //---------------------------------------------------
      // PAGE 3
      //---------------------------------------------------

      const OnboardingModel(
        background: OneDollarWidget(),
        title: "Start with Just \$1.00",
        emoji: "💰",
        subtitle:
        "You don't have to buy a whole share, you can buy a fraction.",
      ),

      //---------------------------------------------------
      // PAGE 4
      //---------------------------------------------------

      const OnboardingModel(
        background: SecurityWidget(),
        title: "Your Safety is First",
        emoji: "🛡️",
        subtitle:
        "Your brokerage account is maintained by Interactive Brokers LLC.",
      ),

      //---------------------------------------------------
      // PAGE 5
      //---------------------------------------------------

      const OnboardingModel(
        background: FreeCommissionWidget(),
        title: "No Commissions",
        emoji: "⚡",
        subtitle:
        "No commissions ever, just invest for free and maximize your returns.",
      ),

      //---------------------------------------------------
      // PAGE 6
      //---------------------------------------------------

      const OnboardingModel(
        background: NoSpreadWidget(),
        title: "No Spreads",
        emoji: "🥷",
        subtitle:
        "No spreads, all your trades execute at the international best bid & offer.",
      ),

      //---------------------------------------------------
      // PAGE 7
      //---------------------------------------------------

      const OnboardingModel(
        background: RealSharesWidget(),
        title: "Backed by Real Shares",
        emoji: "🌍",
        subtitle:
        "All your trades are fully backed by real shares all the time.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            //-------------------------------------------------
            // PAGE VIEW
            //-------------------------------------------------

            Flexible(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  return OnboardingPage(
                    model: pages[index],
                  );
                },
              ),
            ),

            //-------------------------------------------------
            // INDICATOR
            //-------------------------------------------------

            SmoothPageIndicator(
              controller: _pageController,
              count: pages.length,

              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xff22C58B),
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),

            const SizedBox(height: 18),

            //-------------------------------------------------
            // GOOGLE BUTTON
            //-------------------------------------------------

            Obx(
                  () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                    googleAuthController.isLoading.value
                        ? null
                        : googleAuthController.signInWithGoogle,
                    icon: googleAuthController.isLoading.value
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Image.asset(
                      'assets/logos/google.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    label: Text(
                      googleAuthController.isLoading.value
                          ? 'Signing in...'
                          : 'Continue with Google',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            //-------------------------------------------------
            // SIGN UP
            //-------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const SignupScreen(), binding: SignupBinding());
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22C58B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),

                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            //-------------------------------------------------
            // SIGN IN
            //-------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SignInScreen());
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE9FBF5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),

                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Color(0xff22C58B),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}