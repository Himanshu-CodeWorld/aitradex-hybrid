import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class ProfileImageScreen extends StatefulWidget {
  const ProfileImageScreen({super.key});

  @override
  State<ProfileImageScreen> createState() => _ProfileImageScreenState();
}

class _ProfileImageScreenState extends State<ProfileImageScreen> {
  final ImagePicker _picker = ImagePicker();

  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SignupController>();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) return;

      controller.setProfileImage(image.path);
    } catch (e) {
      Get.snackbar(
        'Image Error',
        'Unable to select the image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showImageOptions() async {
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Choose Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff171717),
                ),
              ),
              const SizedBox(height: 18),
              _ImageOptionTile(
                icon: Icons.camera_alt_outlined,
                title: 'Take a photo',
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _ImageOptionTile(
                icon: Icons.photo_library_outlined,
                title: 'Choose from gallery',
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              Obx(
                    () {
                  final bool hasImage =
                      controller.profileImagePath.value.trim().isNotEmpty;

                  if (!hasImage) {
                    return const SizedBox.shrink();
                  }

                  return _ImageOptionTile(
                    icon: Icons.delete_outline,
                    title: 'Remove photo',
                    iconColor: Colors.redAccent,
                    onTap: () {
                      controller.removeProfileImage();
                      Get.back();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _continue() async {
    await controller.saveDraft();
    await controller.nextPage();
  }

  Future<void> _skip() async {
    controller.removeProfileImage();
    await controller.saveDraft();
    await controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Obx(
                  () => SignupProgressHeader(
                currentPage: controller.currentPage.value,
                totalPages: SignupController.totalPages,
                onBack: controller.previousPage,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a profile photo',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff171717),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add a photo so your AiTradeX profile feels more personal. You can skip this step for now.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff777777),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Center(
                      child: Obx(
                            () {
                          final String imagePath =
                          controller.profileImagePath.value.trim();

                          final bool hasImage = imagePath.isNotEmpty;

                          return GestureDetector(
                            onTap: _showImageOptions,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xffF5F5F5),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.18),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: hasImage &&
                                    File(imagePath).existsSync()
                                    ? Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                )
                                    : Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 62,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Add Photo',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showImageOptions,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Choose photo',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xffE5E5E5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use a clear photo of yourself. You can change or remove it later from your profile.',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                height: 1.55,
                                color: const Color(0xff666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Obx(
                          () => PrimaryButton(
                        text: controller.isSubmitting.value
                            ? 'Please wait...'
                            : 'Continue',
                        enabled: !controller.isSubmitting.value,
                        onPressed: controller.isSubmitting.value
                            ? null
                            : _continue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed:
                        controller.isSubmitting.value ? null : _skip,
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff777777),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ImageOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppColors.primary;

    return Material(
      color: const Color(0xffFAFAFA),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 23,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff222222),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xff999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
