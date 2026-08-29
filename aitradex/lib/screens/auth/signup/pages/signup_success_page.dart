import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';

import 'package:aitradex/screens/home/dashboard_screen.dart';

class SignupSuccessPage extends StatefulWidget {
  const SignupSuccessPage({super.key});

  @override
  State<SignupSuccessPage> createState() =>
      _SignupSuccessPageState();
}

class _SignupSuccessPageState extends State<SignupSuccessPage> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      Get.offAll(
            () => const DashboardScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Lottie.asset(
                    "assets/animations/success.json",
                    height: screenHeight * 0.28,
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 120,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Congratulations! 🎉",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Your AiTradeX account has been created successfully.\n\n"
                        "Your identity verification has been submitted and your investment account is ready to use.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Your KYC details have been received successfully. Once verified, you'll be able to invest, trade and manage your portfolio seamlessly.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}