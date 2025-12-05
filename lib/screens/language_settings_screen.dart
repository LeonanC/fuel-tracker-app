import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_language.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen>
    with TickerProviderStateMixin {
  final LanguageController languageController = Get.find<LanguageController>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      final primaryTextColor = theme.colorScheme.onSurface;
      final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

      final currentLanguage = languageController.currentLanguage.value;
      final isRtlLanguage = currentLanguage.isRtl;

      final titleStyle = isRtlLanguage
          ? GoogleFonts.vazirmatn(color: primaryTextColor, fontWeight: FontWeight.bold)
          : theme.appBarTheme.titleTextStyle?.copyWith(color: primaryTextColor);
      final subtitleStyle = isRtlLanguage
          ? GoogleFonts.vazirmatn(fontSize: 16, color: secondaryTextColor)
          : theme.textTheme.titleMedium?.copyWith(color: secondaryTextColor);

      final sectionTextStyle = isRtlLanguage
          ? GoogleFonts.vazirmatn(
              fontSize: 18,
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            )
          : theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            );

      return Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        appBar: AppBar(
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          title: Text(context.tr('language_settings.title'), style: titleStyle),
          centerTitle: false,
          elevation: theme.appBarTheme.elevation,
          iconTheme: theme.appBarTheme.iconTheme,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('language_settings.subtitle'), style: subtitleStyle),
                    const SizedBox(height: 24),
                    _buildCurrentLanguageCard(
                      currentLanguage,
                      isRtlLanguage,
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('language_settings.available_languages'),
                        style: sectionTextStyle,
                      ),
                      Expanded(
                        child: _buildLanguageList(
                          isRtlLanguage,
                          primaryTextColor,
                          secondaryTextColor,
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
    });
  }

  Widget _buildCurrentLanguageCard(
    AppLanguage currentLanguage,
    bool isRtlLanguage,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final languageNameStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(fontSize: 18, color: primaryTextColor, fontWeight: FontWeight.bold)
        : TextStyle(fontSize: 18, color: primaryTextColor, fontWeight: FontWeight.bold);
    final languageCodeStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(fontSize: 14, color: secondaryTextColor)
        : TextStyle(fontSize: 14, color: secondaryTextColor);

    final currentlanguageLabelStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 14,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(fontSize: 14, color: secondaryTextColor, fontWeight: FontWeight.w500);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryFuelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryFuelColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('language_settings.current_language'),
            style: currentlanguageLabelStyle.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(currentLanguage.flag, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLanguage.name,
                    style: languageNameStyle.copyWith(color: AppTheme.textLight),
                  ),
                  Text(
                    currentLanguage.code.toUpperCase(),
                    style: languageCodeStyle.copyWith(color: AppTheme.textLight.withOpacity(0.8)),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.check_circle, color: AppTheme.textLight, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList(bool isRtlLanguage, Color primaryTextColor, Color cardColor) {
    return Obx(() {
      final currentLanguage = languageController.currentLanguage.value;

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: AppLanguage.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = AppLanguage.supportedLanguages[index];
          final isSelected = language == currentLanguage;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            margin: const EdgeInsets.only(bottom: 12.0),
            child: _buildLanguageCard(
              language,
              isSelected,
              index,
              isRtlLanguage,
              primaryTextColor,
              cardColor,
            ),
          );
        },
      );
    });
  }

  Widget _buildLanguageCard(
    AppLanguage language,
    bool isSelected,
    int index,
    bool isRtlLanguage,
    Color primaryTextColor,
    Color cardColor,
  ) {
    final selectedColor = AppTheme.primaryFuelColor;

    final languageNameStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 18,
            color: isSelected ? selectedColor : primaryTextColor,
            fontWeight: FontWeight.bold,
          )
        : TextStyle(
            fontSize: 18,
            color: isSelected ? selectedColor : primaryTextColor,
            fontWeight: FontWeight.bold,
          );
    final languageCodeStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 12,
            color: isSelected ? selectedColor.withValues(alpha: 0.8) : AppTheme.textGrey,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: 12,
            color: isSelected ? selectedColor.withValues(alpha: 0.8) : AppTheme.textGrey,
            fontWeight: FontWeight.w500,
          );

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              color: isSelected ? selectedColor.withValues(alpha: 0.1) : cardColor,

              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? selectedColor.withValues(alpha: 0.5) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: isSelected ? null : () => _changeLanguage(language),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(language.flag, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.name, style: languageNameStyle),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(language.code.toUpperCase(), style: languageCodeStyle),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                        )
                      else
                        Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryFuelColor),
        ),
      ),
    );
    try {
      final success = await languageController.changeLanguage(language);
      Get.back();

      if (success) {
        _showSuccessMessage();
      } else {
        Get.snackbar(
          context.tr('error.title'),
          context.tr('error.failed_to_change_language'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        context.tr('error.title'),
        context.tr('error.generic_error'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void _showSuccessMessage() {
    Get.snackbar(
      context.tr('language_settings.language_changed'),
      context.tr('language_settings.restart_required'),
      backgroundColor: const Color.fromARGB(255, 5, 83, 46),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) {
            Get.back();
          }
        },
        child: Text(
          context.tr('common_labels.ok'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
