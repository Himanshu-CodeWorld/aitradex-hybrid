import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class ProfileImagePage extends StatelessWidget {
  const ProfileImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🟢 ProfileImagePage build() called");
    final SignupController controller = Get.find();

    return SafeArea(
      child: Column(
        children: [
          SignupProgressHeader(
            progress: 0.18,
            onBack: controller.previousPage,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add your profile photo",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "A profile photo helps personalize your account and makes it easier to identify.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: Obx(() {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 75,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            backgroundImage: controller.profileImagePath.value.isNotEmpty
                                ? FileImage(
                              File(controller.profileImagePath.value),
                            )
                                : null,
                            child: controller.profileImagePath.value.isEmpty
                                ? const Icon(
                              Icons.person,
                              size: 75,
                              color: AppColors.primary,
                            )
                                : null,
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () =>
                                _showImagePicker(context, controller),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 45),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        "Choose from Gallery",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await controller.pickProfileImage(
                          ImageSource.gallery,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        "Take Photo",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await controller.pickProfileImage(
                          ImageSource.camera,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Use a clear front-facing photo. You can always change it later from your profile settings.",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: TextButton(
                      onPressed: () async {
                        // Clear selected profile image
                        controller.profileImagePath.value = "";

                        // Clear it from signup model
                        controller.signup.update((user) {
                          user?.profileImage = "";
                        });

                        // Save updated draft
                        await controller.saveCurrentDraft();

                        // Go to next page
                        controller.nextPage();
                      },
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                24,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    text: "Continue",
                    enabled: true,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      // Save selected profile image
                      await controller.saveCurrentDraft();

                      // Next page
                      await controller.nextPage();
                    },
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      // Clear selected profile image
                      controller.profileImagePath.value = "";

                      // Clear image from signup model
                      controller.signup.update((user) {
                        user?.profileImage = "";
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

  void _showImagePicker(
      BuildContext context,
      SignupController controller,
      ) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  Get.back();

                  await controller.pickProfileImage(
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Get.back();

                  await controller.pickProfileImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}