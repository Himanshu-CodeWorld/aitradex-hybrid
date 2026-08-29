import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aitradex/core/theme/app_colors.dart';
import 'signin_controller.dart';
import 'widgets/phone_field.dart';
import 'widgets/continue_button.dart';
import 'package:aitradex/screens/bottomNavigation/bottom_nav.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            /// Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Back Button
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Hello there 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Please enter your mobile number.\nWe'll send a 6-digit OTP for verification.",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 45),

                    /// Phone Field
                    const PhoneField(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const ContinueButton(),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      Get.offAll(
                            () => const BottomNav(),
                      );
                    },
                    child: Text(
                      "Skip for now",
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}