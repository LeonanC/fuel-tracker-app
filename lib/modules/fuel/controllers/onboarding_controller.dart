import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/data/models/onboarding_model.dart';
import 'package:fuel_tracker_app/home_screen.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final LanguageController languageController = Get.find();
  final currentPage = 0.obs;
  late PageController pageController;

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
  }

  final onboardingPages = [
    OnboardingModel(
      titleKey: TranslationKeys.title1,
      descKey: TranslationKeys.desc1,
      icon: Icons.local_gas_station_rounded,
    ),
    OnboardingModel(
      titleKey: TranslationKeys.title2,
      descKey: TranslationKeys.desc2,
      icon: Icons.analytics_rounded,
    ),
    OnboardingModel(
      titleKey: TranslationKeys.title3,
      descKey: TranslationKeys.desc3,
      icon: Icons.savings_rounded,
    ),
  ];

  int get numPages => onboardingPages.length;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void navigateToHomeScreen() {
    Get.offAll(() => const HomePage());
  }

  void handleActionButton() {
    if (currentPage.value == numPages - 1) {
      navigateToHomeScreen();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  }
}
