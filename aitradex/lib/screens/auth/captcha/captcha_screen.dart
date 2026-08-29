import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../signup/signup_controller.dart';
import 'captcha_controller.dart';
import 'widgets/continue_button.dart';

class CaptchaScreen extends StatefulWidget {
  const CaptchaScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen>
    with WidgetsBindingObserver {
  late final CaptchaController controller;
  bool _browserOpened = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (Get.isRegistered<CaptchaController>()) {
      controller = Get.find<CaptchaController>();
    } else {
      controller = Get.put(CaptchaController());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      _browserOpened = true;
      return;
    }

    if (state != AppLifecycleState.resumed || !_browserOpened) {
      return;
    }

    _browserOpened = false;

    // Wait for browser to close completely
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final signup = Get.find<SignupController>();

    // Mark email verified
    signup.signup.update((user) {
      if (user == null) return;

      user.email = widget.email;
      user.emailVerified = true;
    });

    await signup.saveCurrentDraft();

    // Return success to EmailPage
    Get.back(result: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (Get.isRegistered<CaptchaController>()) {
      Get.delete<CaptchaController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Human Verification",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.red,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Verify You're Human",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "For your security, verification will open in your browser using Cloudflare Turnstile.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Security Check",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Tap Continue below. Your default browser will open Cloudflare Turnstile. After successful verification you'll automatically return to AiTradeX.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade700,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 40),

              ContinueButton(
                email: widget.email,
              ),

              const SizedBox(height: 18),

              Text(
                "Protected by Cloudflare Turnstile",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}