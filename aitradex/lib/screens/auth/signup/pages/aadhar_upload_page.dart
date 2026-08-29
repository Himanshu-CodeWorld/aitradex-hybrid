import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import 'package:aitradex/services/kyc_service.dart';
import '../signup_controller.dart';

class AadhaarUploadPage extends StatefulWidget {
  const AadhaarUploadPage({super.key});

  @override
  State<AadhaarUploadPage> createState() =>
      _AadhaarUploadPageState();
}

class _AadhaarUploadPageState
    extends State<AadhaarUploadPage> {
  final SignupController controller = Get.find();

  final ImagePicker _picker = ImagePicker();
  final KycService _kycService = KycService();

  Future<void> _pickImage({
    required bool isFront,
    required ImageSource source,
  }) async {

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    final result = await _kycService.verifyDocument(
      image: File(image.path),
      type: isFront
          ? "aadhaar_front"
          : "aadhaar_back",
    );

    Get.back();

    if (!result.success) {
      Get.snackbar(
        "Verification Failed",
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    if (isFront) {
      controller.aadhaarFrontImagePath.value = image.path;

      controller.signup.update((user) {
        user?.aadhaarFrontUrl = image.path;
      });
    } else {
      controller.aadhaarBackImagePath.value = image.path;

      controller.signup.update((user) {
        user?.aadhaarBackUrl = image.path;
      });
    }

    await controller.saveCurrentDraft();

    Get.snackbar(
      "Verified",
      result.message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showImagePicker(bool isFront) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "Select Image",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 25),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt),
                  ),
                  title: Text(
                    "Take Photo",
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _pickImage(
                      isFront: isFront,
                      source: ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.photo),
                  ),
                  title: Text(
                    "Choose from Gallery",
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _pickImage(
                      isFront: isFront,
                      source: ImageSource.gallery,
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool frontUploaded =
          controller.aadhaarFrontImagePath.value.isNotEmpty;

      final bool backUploaded =
          controller.aadhaarBackImagePath.value.isNotEmpty;

      return SafeArea(
        child: Column(
          children: [
            SignupProgressHeader(
              progress: 0.68,
              onBack: controller.previousPage,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      "Upload Aadhaar Card 🪪",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Upload clear images of both sides of your Aadhaar card for KYC verification.",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    Text(
                      "Front Side",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildUploadCard(
                      isFront: true,
                      title: "Upload Front Side",
                      imagePath: controller.aadhaarFrontImagePath.value,
                      onDelete: () async {
                        controller.aadhaarFrontImagePath.value = "";

                        controller.signup.update((user) {
                          user?.aadhaarFrontUrl = "";
                        });

                        await controller.saveCurrentDraft();
                      },
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Supported formats: JPG, PNG • Max size: 10 MB",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "Back Side",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildUploadCard(
                      isFront: false,
                      title: "Upload Back Side",
                      imagePath: controller.aadhaarBackImagePath.value,
                      onDelete: () async {
                        controller.aadhaarBackImagePath.value = "";

                        controller.signup.update((user) {
                          user?.aadhaarBackUrl = "";
                        });

                        await controller.saveCurrentDraft();
                      },
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Supported formats: JPG, PNG • Max size: 10 MB",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    text: "Continue",
                    enabled: frontUploaded && backUploaded,
                    onPressed: frontUploaded && backUploaded
                        ? () async {
                      await controller.saveCurrentDraft();
                      controller.nextPage();
                    }
                        : null,
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () async {
                      controller.signup.update((user) {
                        user?.aadhaarFrontUrl = "";
                        user?.aadhaarBackUrl = "";
                      });

                      await controller.saveCurrentDraft();

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
          ],
        ),
      );
    });
  }

  Widget _buildUploadCard({
    required bool isFront,
    required String title,
    required String imagePath,
    required VoidCallback onDelete,
  }) {
    final uploaded = imagePath.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: uploaded
              ? Colors.green.shade300
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: uploaded
          ? SizedBox(
        height: 260,
        child: _buildUploadedCard(
          imagePath: imagePath,
          onDelete: onDelete,
          onReplace: () => _showImagePicker(isFront),
        ),
      )
          : _buildEmptyCard(
        title: title,
        onCamera: () => _pickImage(
          isFront: isFront,
          source: ImageSource.camera,
        ),
        onGallery: () => _pickImage(
          isFront: isFront,
          source: ImageSource.gallery,
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                "🪪",
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Choose how you want to upload",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUploadedCard({
    required String imagePath,
    required VoidCallback onDelete,
    required VoidCallback onReplace,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Unable to load image",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  "Uploaded",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 18,
          left: 18,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onReplace,
            icon: const Icon(Icons.refresh),
            label: const Text("Replace"),
          ),
        ),

        Positioned(
          bottom: 18,
          right: 18,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text("Delete"),
          ),
        ),
      ],
    );
  }
}