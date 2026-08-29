import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class DigitalSignaturePage extends StatefulWidget {
  const DigitalSignaturePage({super.key});

  @override
  State<DigitalSignaturePage> createState() =>
      _DigitalSignaturePageState();
}

class _DigitalSignaturePageState
    extends State<DigitalSignaturePage> {
  final SignupController controller = Get.find();

  final GlobalKey<SfSignaturePadState> signatureKey = GlobalKey();

  late final TextEditingController nameController;

  final hasSigned = false.obs;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: controller.fullNameController.text,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveSignature() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your full name.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!hasSigned.value) {
      Get.snackbar(
        "Required",
        "Please provide your digital signature.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save updated name
    controller.fullNameController.text = nameController.text.trim();

    final image = await signatureKey.currentState?.toImage();

    if (image == null) {
      Get.snackbar(
        "Error",
        "Unable to capture signature.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      Get.snackbar(
        "Error",
        "Unable to process signature.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final signatureBytes = byteData.buffer.asUint8List();

    controller.signup.update((user) {
      if (user == null) return;

      user.fullName = nameController.text.trim();

      // TODO:
      // Upload signatureBytes to Cloudinary/Backend
      // user.signatureUrl = uploadedUrl;
    });

    controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      "Last step, can we get\nyour digital signature? ✍️",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Full Name",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Enter your full name",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Listener(
                          onPointerDown: (_) {
                            if (!hasSigned.value) {
                              hasSigned.value = true;
                            }
                          },
                          child: SfSignaturePad(
                            key: signatureKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            minimumStrokeWidth: 3,
                            maximumStrokeWidth: 5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          signatureKey.currentState?.clear();
                          hasSigned.value = false;
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Clear Signature",
                          style:
                          GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Obx(
                      () => PrimaryButton(
                    text: "Continue",
                    enabled: hasSigned.value,
                    onPressed: hasSigned.value
                        ? () async {
                      await saveSignature();
                    }
                        : null,
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