import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/theme/app_colors.dart';
import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class ReviewInformationPage extends StatefulWidget {
  const ReviewInformationPage({
    super.key,
  });

  @override
  State<ReviewInformationPage> createState() =>
      _ReviewInformationPageState();
}

class _ReviewInformationPageState extends State<ReviewInformationPage> {
  late final SignupController controller;

  bool agreed = false;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _valueOrFallback(
      String value, {
        String fallback = 'Not provided',
      }) {
    final String trimmed = value.trim();

    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _maskedPassword() {
    return '••••••••';
  }

  String _formatPhone(String phone) {
    final String value = phone.trim();

    if (value.isEmpty) {
      return 'Not provided';
    }

    if (value.startsWith('+91') && value.length > 7) {
      return '${value.substring(0, 3)} '
          '${value.substring(3, 6)} '
          '${value.substring(6, 9)} '
          '${value.substring(9)}';
    }

    if (value.length == 10) {
      return '+91 '
          '${value.substring(0, 3)} '
          '${value.substring(3, 6)} '
          '${value.substring(6)}';
    }

    return value;
  }

  String _profileImageText() {
    final String path = controller.profileImagePath.value.trim();

    if (path.isEmpty) {
      return 'Not added';
    }

    return 'Profile photo selected';
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ===========================================================================
  // INFORMATION TILE
  // ===========================================================================

  Widget _infoTile(
      String title,
      String value,
      IconData icon, {
        bool verified = false,
      }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          if (verified) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.verified,
              color: Colors.green,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // VERIFICATION TILE
  // ===========================================================================

  Widget _verificationTile(
      String title,
      bool verified,
      IconData icon,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: verified
              ? Colors.green.withValues(
            alpha: 0.25,
          )
              : Colors.orange.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: verified ? Colors.green : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: verified
                  ? Colors.green.withValues(
                alpha: 0.10,
              )
                  : Colors.orange.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              verified ? 'Verified' : 'Pending',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: verified ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE IMAGE PREVIEW
  // ===========================================================================

  Widget _profileImagePreview() {
    final String imagePath =
    controller.profileImagePath.value.trim();

    final bool hasImage = imagePath.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: hasImage
                ? Image.file(
              File(
                imagePath,
              ),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 52,
                  height: 52,
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                );
              },
            )
                : Container(
              width: 52,
              height: 52,
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileImageText(),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          if (hasImage)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CREATE ACCOUNT
  // ===========================================================================

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    // Prevent double taps.
    if (controller.isSubmitting.value) {
      return;
    }

    if (!agreed) {
      Get.snackbar(
        'Confirmation Required',
        'Please confirm that your information is correct.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    // -------------------------------------------------------------------------
    // FINAL ACCOUNT CREATION
    // -------------------------------------------------------------------------

    final bool success = await controller.createAccount();

    // Never leave review page when creation fails.
    if (!success || !mounted) {
      return;
    }

    // -------------------------------------------------------------------------
    // ACCOUNT CREATED
    // -------------------------------------------------------------------------
    //
    // Clear signup stack and send user to login.
    //
    // -------------------------------------------------------------------------

    Get.offAllNamed(
      '/login',
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final String name = _valueOrFallback(
      controller.nameController.text,
    );

    final String email = _valueOrFallback(
      controller.emailController.text,
    );

    final String phone = _formatPhone(
      controller.phoneController.text,
    );

    final String username = _valueOrFallback(
      controller.usernameController.text,
    );

    final String referralCode = _valueOrFallback(
      controller.referralCode,
      fallback: 'No referral code',
    );

    final bool emailVerified =
        controller.emailVerified.value;

    final bool phoneVerified =
        controller.phoneVerified.value;

    return SafeArea(
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // PROGRESS HEADER
          // -------------------------------------------------------------------

          SignupProgressHeader(
            currentPage: controller.currentPage.value,
            totalPages: SignupController.totalPages,
            onBack: controller.previousPage,
          ),

          // -------------------------------------------------------------------
          // CONTENT
          // -------------------------------------------------------------------

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // TITLE
                  // -----------------------------------------------------------

                  Text(
                    'Review Your Information',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Please review your information carefully before creating your account.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // -----------------------------------------------------------
                  // PERSONAL INFORMATION
                  // -----------------------------------------------------------

                  _sectionTitle(
                    'Personal Information',
                  ),

                  _infoTile(
                    'Full Name',
                    name,
                    Icons.person_outline,
                  ),

                  _infoTile(
                    'Email Address',
                    email,
                    Icons.email_outlined,
                    verified: emailVerified,
                  ),

                  _infoTile(
                    'Phone Number',
                    phone,
                    Icons.phone_outlined,
                    verified: phoneVerified,
                  ),

                  const SizedBox(height: 16),

                  // -----------------------------------------------------------
                  // ACCOUNT INFORMATION
                  // -----------------------------------------------------------

                  _sectionTitle(
                    'Account Information',
                  ),

                  _infoTile(
                    'Username',
                    username,
                    Icons.alternate_email,
                  ),

                  _infoTile(
                    'Password',
                    _maskedPassword(),
                    Icons.lock_outline,
                  ),

                  const SizedBox(height: 16),

                  // -----------------------------------------------------------
                  // PROFILE
                  // -----------------------------------------------------------

                  _sectionTitle(
                    'Profile',
                  ),

                  _profileImagePreview(),

                  _infoTile(
                    'Referral Code',
                    referralCode,
                    Icons.card_giftcard_outlined,
                  ),

                  const SizedBox(height: 16),

                  // -----------------------------------------------------------
                  // VERIFICATION STATUS
                  // -----------------------------------------------------------

                  _sectionTitle(
                    'Verification Status',
                  ),

                  _verificationTile(
                    'Email Verification',
                    emailVerified,
                    Icons.email_outlined,
                  ),

                  _verificationTile(
                    'Phone Verification',
                    phoneVerified,
                    Icons.phone_android_outlined,
                  ),

                  const SizedBox(height: 8),

                  // -----------------------------------------------------------
                  // SECURITY INFORMATION
                  // -----------------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.06,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your password is securely managed by Firebase Authentication and is never displayed here.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              height: 1.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -----------------------------------------------------------
                  // CONFIRMATION
                  // -----------------------------------------------------------

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: agreed,
                      activeColor: AppColors.primary,
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      controlAffinity:
                      ListTileControlAffinity.leading,
                      title: Text(
                        'I confirm that all the information above is correct and I want to create my AiTradeX account.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          agreed = value ?? false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // CREATE ACCOUNT BUTTON
          // -------------------------------------------------------------------

          Obx(
                () {
              final bool isSubmitting =
                  controller.isSubmitting.value;

              final bool canCreate =
                  agreed && !isSubmitting;

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  16,
                ),
                child: PrimaryButton(
                  text: isSubmitting
                      ? 'Creating Account...'
                      : 'Create Account',
                  enabled: canCreate,
                  onPressed: canCreate
                      ? _createAccount
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}