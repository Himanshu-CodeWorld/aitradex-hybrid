import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/core/widgets/primary_button.dart';
import 'package:aitradex/core/widgets/signup_progress_header.dart';

import '../signup_controller.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  late final SignupController controller;

  late final TextEditingController referralController;
  late final FocusNode referralFocusNode;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SignupController>();

    referralController = TextEditingController(
      text: controller.referralCode.trim().toUpperCase(),
    );

    referralFocusNode = FocusNode();

    referralController.addListener(_onReferralChanged);
  }

  void _onReferralChanged() {
    final String normalized =
    referralController.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

    if (normalized != referralController.text) {
      referralController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(
          offset: normalized.length,
        ),
      );
    }

    controller.setReferralCode(normalized);
  }

  @override
  void dispose() {
    referralController.removeListener(_onReferralChanged);
    referralController.dispose();
    referralFocusNode.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final String referralCode =
    referralController.text.trim().toUpperCase();

    controller.setReferralCode(referralCode);

    await controller.saveDraft();
    await controller.nextPage();
  }

  Future<void> _skip() async {
    FocusScope.of(context).unfocus();

    referralController.clear();

    controller.setReferralCode('');

    await controller.saveDraft();
    await controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color primary = scheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -----------------------------------------------------------
                    // HEADER
                    // -----------------------------------------------------------

                    Text(
                      'Got a referral code?',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        height: 1.18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Enter the code shared by your friend. '
                          'This helps us connect your account to their referral.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurface.withValues(
                          alpha: 0.62,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------------
                    // REFERRAL CODE LABEL
                    // -----------------------------------------------------------

                    Text(
                      'Referral code',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // -----------------------------------------------------------
                    // REFERRAL CODE INPUT
                    // -----------------------------------------------------------

                    TextField(
                      controller: referralController,
                      focusNode: referralFocusNode,
                      textCapitalization:
                      TextCapitalization.characters,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLength: 20,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        UpperCaseTextFormatter(),
                      ],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: scheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. ATX8K4P2',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: scheme.onSurface.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.card_giftcard_rounded,
                          color: primary,
                        ),
                        filled: true,
                        fillColor: scheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 17,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: scheme.onSurface.withValues(
                              alpha: 0.10,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _continue(),
                    ),

                    const SizedBox(height: 16),

                    // -----------------------------------------------------------
                    // REWARD INFORMATION
                    // -----------------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                              BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.redeem_rounded,
                              color: primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Referral rewards',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your friend can earn 250 AiTradeX Coins '
                                      'when your referral is successfully completed.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // -----------------------------------------------------------
                    // OPTIONAL INFO
                    // -----------------------------------------------------------

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: scheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is optional. You can continue without a referral code.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              height: 1.45,
                              color: scheme.onSurface.withValues(
                                alpha: 0.52,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // -----------------------------------------------------------
                    // CONTINUE
                    // -----------------------------------------------------------

                    Obx(
                          () => PrimaryButton(
                        text: controller.isSubmitting.value
                            ? 'Please wait...'
                            : 'Continue',
                        enabled:
                        !controller.isSubmitting.value,
                        onPressed:
                        controller.isSubmitting.value
                            ? null
                            : _continue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // -----------------------------------------------------------
                    // SKIP
                    // -----------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed:
                        controller.isSubmitting.value
                            ? null
                            : _skip,
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(
                              alpha: 0.52,
                            ),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String upperCaseText =
    newValue.text.toUpperCase();

    final int offset = upperCaseText.length;

    return TextEditingValue(
      text: upperCaseText,
      selection: TextSelection.collapsed(
        offset: offset,
      ),
      composing: TextRange.empty,
    );
  }
}