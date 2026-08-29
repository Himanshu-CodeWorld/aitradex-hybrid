import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class SelfieVerificationPage extends StatefulWidget {
  const SelfieVerificationPage({super.key});

  @override
  State<SelfieVerificationPage> createState() =>
      _SelfieVerificationPageState();
}

class _SelfieVerificationPageState
    extends State<SelfieVerificationPage> {
  final SignupController controller = Get.find();
  final ImagePicker picker = ImagePicker();

  Future<void> takeSelfie() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 90,
    );

    if (image != null) {
      controller.selfieImagePath.value = image.path;

      await controller.saveCurrentDraft();

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.65,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "Verify Your Identity 📸",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Take a clear selfie to complete your identity verification.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: takeSelfie,
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),
                          width: 280,
                          height: 380,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(.05),
                            borderRadius:
                            BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: controller.selfieImagePath.value.isEmpty
                              ? Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor:
                                AppColors.primary,
                                child: const Icon(
                                  Icons
                                      .camera_alt_rounded,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Tap to Take Selfie",
                                style:
                                GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Use your front camera",
                                style:
                                GoogleFonts.poppins(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                              : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                    22),
                                child: Image.file(
                                  File(controller.selfieImagePath.value),
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                top: 12,
                                right: 12,
                                child: CircleAvatar(
                                  backgroundColor:
                                  Colors.red,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color:
                                      Colors.white,
                                    ),
                                    onPressed:
                                    takeSelfie,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Remove sunglasses, hats, and masks. Make sure your face is fully visible and well lit.",
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
            padding:
            const EdgeInsets.fromLTRB(
                24, 12, 24, 24),
            child: PrimaryButton(
              text: "Continue",
              enabled: controller.selfieImagePath.value.isNotEmpty,
              onPressed: () async {
                if (controller.selfieImagePath.value.isEmpty) return;

                await controller.saveCurrentDraft();

                await controller.nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}