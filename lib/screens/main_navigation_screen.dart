import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/onboarding_controller.dart';
import 'package:fuel_tracker_app/models/onboarding_model.dart';
import 'package:fuel_tracker_app/screens/home_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';

class AppTheme2 {
  static const Color primaryFuelColor = Color(0xFF007BFF);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColorLight = Colors.white;
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color cardColorDark = Color(0xFF1E1E1E);
}

class TranslationKeys2 {
  static const String onboardings = "";
  static const String onboardingButtonStart = "Começar Agora";
  static const String onboardingButtonNext = "Próximo";
  static const String onboardingButtonSkip = "Pular";
  static const String title1 = "Rastreie Seu Combustível";
  static const String desc1 = "Registre cada abastecimento para monitorar seu consumo e custo.";
  static const String title2 = "Análise de Desempenho";
  static const String desc2 =
      "Veja gráfico e relatórios detalhados sobre a eficiência do seu  veículo.";
  static const String title3 = "Economize Dinheiro";
  static const String desc3 =
      "Identifique padrões de gasto e encontre as melhores estratégias para economizar.";
}

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  ? controller.tr(TranslationKeys2.onboardingButtonStart)
                  : controller.tr(TranslationKeys2.onboardingButtonNext),
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
    final theme = Get.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 180.0, color: AppTheme2.primaryFuelColor),
          const SizedBox(height: 50.0),
          Text(
            tr(data.titleKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 30.0,
              fontWeight: FontWeight.w900,
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15.0),
          Text(
            tr(data.descKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 17.0,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
