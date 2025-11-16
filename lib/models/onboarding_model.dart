import 'package:flutter/material.dart';

class OnboardingModel {
  final String titleKey;
  final String descKey;
  final IconData icon;

  const OnboardingModel({
    required this.titleKey,
    required this.descKey,
    required this.icon,
  });
}