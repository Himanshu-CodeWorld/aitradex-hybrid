import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

import 'package:aitradex/screens/bottomNavigation/bottom_nav.dart';
import 'package:aitradex/services/shared_preferences_service.dart';

class CreateMpinPage extends StatefulWidget {
  const CreateMpinPage({super.key});

  @override
  State<CreateMpinPage> createState() => _CreateMpinPageState();
}

class _CreateMpinPageState extends State<CreateMpinPage> {
  final SignupController controller = Get.find();

  final TextEditingController mpinController =
  TextEditingController();

  final TextEditingController confirmController =
  TextEditingController();

  bool obscurePin = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    mpinController.addListener(() => setState(() {}));
    confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    mpinController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get isValid {
    final mpin = mpinController.text.trim();
    final confirm = confirmController.text.trim();

    return RegExp(r'^\d{6}$').hasMatch(mpin) &&
        mpin == confirm;
  }

  Widget pinField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 10,
      ),
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.primary,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showError =
        confirmController.text.isNotEmpty &&
            mpinController.text != confirmController.text;

    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.95,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Your MPIN 🔐",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your 6-digit MPIN will be required every time you log in or authorize sensitive actions.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  pinField(
                    label: "Create MPIN",
                    controller: mpinController,
                    obscure: obscurePin,
                    onToggle: () {
                      setState(() {
                        obscurePin = !obscurePin;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  pinField(
                    label: "Confirm MPIN",
                    controller: confirmController,
                    obscure: obscureConfirm,
                    onToggle: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),

                  if (showError)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Text(
                        "MPIN does not match.",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.security,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Choose a unique 6-digit MPIN. Do not share it with anyone. You will use it to authorize secure transactions.",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.5,
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

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Obx(
                      () => PrimaryButton(
                    text: controller.isSubmitting.value
                        ? "Creating Account..."
                        : "Create Account",
                    enabled: isValid && !controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                      if (!isValid) {
                        Get.snackbar(
                          "Invalid MPIN",
                          "Please enter a valid 6-digit MPIN and confirm it.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      FocusScope.of(context).unfocus();

                      // Save MPIN
                      controller.signup.update((user) {
                        user?.mpin = mpinController.text.trim();
                      });

                      // Sync all fields
                      controller.updateSignupModel();

                      debugPrint("========== CREATE ACCOUNT ==========");
                      debugPrint(controller.signup.value.toJson().toString());

                      await controller.createAccount();
                    },
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                    await SharedPreferencesService.setLoggedIn(true);

                    Get.offAll(
                          () => const BottomNav(),
                    );
                  },
                  child: Text(
                    "Go to Dashboard",
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
    );
  }
}