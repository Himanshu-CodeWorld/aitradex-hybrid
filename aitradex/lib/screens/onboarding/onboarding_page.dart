import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aitradex/models/onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPage({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                SizedBox(
                  height: constraints.maxHeight * .52,
                  child: Center(
                    child: model.background,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  model.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (model.emoji.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      model.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),

                const SizedBox(height: 12),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    model.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}