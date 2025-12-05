import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/models/onboarding_model.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class OnboardingController extends GetxController {
  final LanguageController languageController = Get.find<LanguageController>();

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
  }

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      titleKey: TranslationKeys.onboardingsTitle1,
      descKey: TranslationKeys.onboardingsDesc1,
      icon: RemixIcons.line_chart_line,
    ),
    OnboardingModel(
      titleKey: TranslationKeys.onboardingsTitle2,
      descKey: TranslationKeys.onboardingsDesc2,
      icon: RemixIcons.car_line,
    ),
    OnboardingModel(
      titleKey: TranslationKeys.onboardingsTitle3,
      descKey: TranslationKeys.onboardingsDesc3,
      icon: RemixIcons.bill_line,
    ),
  ];

  final RxInt currentPage = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }
  
  int get numPages => onboardingPages.length;

  void onPageChanged(int page){
    currentPage.value = page;
  }

  void handleActionButton(){
    if(currentPage.value == numPages -1){
      navigateToHomeScreen();
    }else{
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  }

  void navigateToHomeScreen() {
    Get.offAll(() => const MainNavigationScreen());
  }

}
