import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';
import '../signup_controller.dart';

class PanCardUploadPage extends StatefulWidget {
  const PanCardUploadPage({super.key});

  @override
  State<PanCardUploadPage> createState() =>
      _PanCardUploadPageState();
}

class _PanCardUploadPageState
    extends State<PanCardUploadPage> {
  final SignupController controller = Get.find();
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return;

    controller.panImagePath.value = image.path;

    controller.signup.update((user) {
      user?.panImageUrl = image.path;
    });

    await controller.saveCurrentDraft();
  }

  void showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.55,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    "Upload your PAN Card 🪪",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We use your PAN card to complete your KYC verification.",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Obx(
                        () => GestureDetector(
                      onTap: showPicker,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: double.infinity,
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          color: AppColors.primary.withValues(alpha: 0.04),
                        ),
                        child: controller.panImagePath.value.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.credit_card,
                              size: 80,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Tap to upload PAN Card",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Camera or Gallery",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                            : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(
                                File(controller.panImagePath.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    controller.panImagePath.value = "";

                                    controller.signup.update((user) {
                                      user?.panImageUrl = "";
                                    });

                                    await controller.saveCurrentDraft();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Obx(
                  () => PrimaryButton(
                text: "Continue",
                enabled: controller.panImagePath.value.isNotEmpty,
                onPressed: controller.panImagePath.value.isEmpty
                    ? null
                    : () async {
                  FocusScope.of(context).unfocus();

                  // Save local image path
                  controller.signup.update((user) {
                    user?.panImageUrl = controller.panImagePath.value;
                  });

                  await controller.saveCurrentDraft();

                  controller.nextPage();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}