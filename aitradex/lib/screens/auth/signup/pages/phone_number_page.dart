import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import 'package:aitradex/screens/auth/signin/signin_service.dart';
import 'package:aitradex/screens/auth/otp/otp_verification_screen.dart';

import 'package:aitradex/screens/auth/signup/signup_controller.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final SignupController controller = Get.find();

  bool isButtonEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    debugPrint("Phone Controller Hash: ${controller.hashCode}");

    controller.phoneController.addListener(() {
      setState(() {
        isButtonEnabled = RegExp(r'^[0-9]{10}$')
            .hasMatch(controller.phoneController.text.trim());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.15,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's your phone number? 📱",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We'll send a verification OTP to this mobile number.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Mobile Number",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          alignment: Alignment.center,
                          child: Text(
                            "+91",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),

                        Expanded(
                          child: TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: "9876543210",
                              border: InputBorder.none,
                              counterText: "",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ),

                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your mobile number is used for OTP verification and account security.",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // SafeArea(
          //   top: false,
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(
          //       24,
          //       0,
          //       24,
          //       24,
          //     ),
          //     child: PrimaryButton(
          //       text: isLoading ? "Sending OTP..." : "Continue",
          //       enabled: isButtonEnabled && !isLoading,
          //       onPressed: isLoading
          //           ? null
          //           : () async {
          //         FocusScope.of(context).unfocus();
          //
          //         setState(() {
          //           isLoading = true;
          //         });
          //
          //         try {
          //           final phone = controller.phoneController.text.trim();
          //
          //           const countryCode = "+91";
          //           final fullPhone = "$countryCode$phone";
          //
          //           // Save phone in signup model
          //           controller.signup.update((user) {
          //             user?.phone = phone;
          //             user?.countryCode = countryCode;
          //           });
          //
          //           await controller.saveCurrentDraft();
          //
          //           final result = await SignInService.sendPhoneOtp(
          //             phone: fullPhone,
          //           );
          //
          //           debugPrint("========== SEND OTP ==========");
          //           debugPrint(result.toString());
          //
          //           if (result["success"] == true) {
          //             final verified = await Get.to<bool>(
          //                   () => OtpVerificationScreen(phone: fullPhone),
          //             );
          //
          //             debugPrint("OTP Screen returned: $verified");
          //
          //             if (verified == true && mounted) {
          //               WidgetsBinding.instance.addPostFrameCallback((_) {
          //                 controller.nextPage();
          //               });
          //             }
          //           } else {
          //             Get.snackbar(
          //               "Failed",
          //               result["message"] ?? "Unable to send OTP.",
          //               snackPosition: SnackPosition.BOTTOM,
          //             );
          //           }
          //         } catch (e) {
          //           debugPrint("OTP ERROR: $e");
          //
          //           Get.snackbar(
          //             "Error",
          //             e.toString(),
          //             snackPosition: SnackPosition.BOTTOM,
          //           );
          //         } finally {
          //           if (mounted) {
          //             setState(() {
          //               isLoading = false;
          //             });
          //           }
          //         }
          //       },
          //     ),
          //
          //   ),
          // ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    text: isLoading ? "Sending OTP..." : "Continue",
                    enabled: isButtonEnabled && !isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                      FocusScope.of(context).unfocus();

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        final phone =
                        controller.phoneController.text.trim();

                        const countryCode = "+91";
                        final fullPhone = "$countryCode$phone";

                        // Save phone in signup model
                        controller.signup.update((user) {
                          user?.phone = phone;
                          user?.countryCode = countryCode;
                        });

                        await controller.saveCurrentDraft();

                        final result =
                        await SignInService.sendPhoneOtp(
                          phone: fullPhone,
                        );

                        debugPrint("========== SEND OTP ==========");
                        debugPrint(result.toString());

                        if (result["success"] == true) {
                          final verified =
                          await Get.to<bool>(
                                () => OtpVerificationScreen(
                              phone: fullPhone,
                            ),
                          );

                          debugPrint(
                              "OTP Screen returned: $verified");

                          if (verified == true && mounted) {
                            controller.signup.update((user) {
                              if (user == null) return;

                              user.phone = phone;
                              user.countryCode = countryCode;
                              user.phoneVerified = true;
                            });

                            await controller.saveCurrentDraft();

                            controller.nextPage();
                          }
                        } else {
                          Get.snackbar(
                            "Failed",
                            result["message"] ??
                                "Unable to send OTP.",
                            snackPosition:
                            SnackPosition.BOTTOM,
                          );
                        }
                      } catch (e) {
                        debugPrint("OTP ERROR: $e");

                        Get.snackbar(
                          "Error",
                          e.toString(),
                          snackPosition:
                          SnackPosition.BOTTOM,
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      FocusScope.of(context).unfocus();

                      // Clear phone number
                      controller.phoneController.clear();

                      // Clear signup model values
                      controller.signup.update((user) {
                        if (user == null) return;

                        user.phone = "";
                        user.countryCode = "+91";
                        user.phoneVerified = false;
                      });

                      // Save draft
                      await controller.saveCurrentDraft();

                      // Go to next page
                      controller.nextPage();
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
          ),
        ],
      ),
    );
  }
}