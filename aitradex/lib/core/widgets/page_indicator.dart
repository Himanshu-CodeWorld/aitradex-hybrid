import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const CustomPageIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        expansionFactor: 2.8,
        spacing: 6,
        radius: 10,
        dotWidth: 10,
        dotHeight: 10,
        strokeWidth: 0,

        /// Active Dot
        activeDotColor: const Color(0xFF4F5DFF),

        /// Inactive Dot
        dotColor: Colors.grey.shade300,
      ),
    );
  }
}