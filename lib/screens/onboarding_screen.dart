import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/onboarding_controller.dart';
import 'package:fuel_tracker_app/models/onboarding_model.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.navigateToHomeScreen,
                child: Text(
                  controller.tr(TranslationKeys.onboardingsButtonSkip),
                  style: TextStyle(color: AppTheme.primaryFuelColor),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.numPages,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (_, index) {
                  return OnboardingPageContent(data: controller.onboardingPages[index]);
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.numPages,
                  (index) => _buildPageIndicator(context, index, controller.currentPage.value),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int index, int currentPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: (index == currentPage) ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: (index == currentPage) ? AppTheme.primaryFuelColor : Colors.grey.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.handleActionButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryFuelColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              controller.currentPage.value == controller.numPages - 1
                  ? controller.tr(TranslationKeys.onboardingsButtonStart)
                  : controller.tr(TranslationKeys.onboardingsButtonNext),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final OnboardingModel data;
  OnboardingPageContent({required this.data});

  final LanguageController languageController = Get.find<LanguageController>();

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 150.0, color: AppTheme.primaryFuelColor),
          const SizedBox(height: 30.0),
          Text(
            tr(data.titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 15.0),
          Text(
            tr(data.descKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
