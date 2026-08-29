import 'package:flutter/material.dart';

class OnboardingModel {
  final Widget background;
  final String title;
  final String subtitle;
  final String emoji;

  const OnboardingModel({
    required this.background,
    required this.title,
    required this.subtitle,
    this.emoji = '',
  });
}