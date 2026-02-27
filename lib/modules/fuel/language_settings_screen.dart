import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/app_language.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen>
    with TickerProviderStateMixin {
  final LanguageController _languageController = Get.find<LanguageController>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  TextStyle _getResponsiveStyle(
    BuildContext context, {
    required bool isRtl,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    if (isRtl) {
      return GoogleFonts.vazirmatn(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Obx(
          () => Text(
            context.tr('language_settings.title'),
            style: _getResponsiveStyle(
              context,
              isRtl: _languageController.currentLanguage.isRtl,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        centerTitle: false,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      context.tr('language_settings.subtitle'),
                      style: _getResponsiveStyle(
                        context,
                        isRtl: _languageController.currentLanguage.isRtl,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => _buildCurrentLanguageCard(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(
                () => Text(
                  context.tr('language_settings.available_languages'),
                  style: _getResponsiveStyle(
                    context,
                    isRtl: _languageController.currentLanguage.isRtl,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildLanguageList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLanguageCard(BuildContext context) {
    final lang = _languageController.currentLanguage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryFuelColor,
            AppTheme.primaryFuelColor.withBlue(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryFuelColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('language_settings.current_language').toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(lang.flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: _getResponsiveStyle(
                      context,
                      isRtl: lang.isRtl,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    lang.code.toUpperCase(),
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.stars_rounded, color: Colors.white, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: AppLanguage.supportedLanguages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final language = AppLanguage.supportedLanguages[index];

        return Obx(() {
          final isSelected = language == _languageController.currentLanguage;
          return _LanguageTile(
            language: language,
            isSelected: isSelected,
            onTap: () => _changeLanguage(language),
          );
        });
      },
    );
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    if (language == _languageController.currentLanguage) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryFuelColor),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await _languageController.changeLanguage(language);
      Get.back();

      if (success) {
        _showSnackBar(
          context.tr('language_settings.language_changed'),
          context.tr('language_settings.restart_required'),
          isError: false,
        );
      }
    } catch (e) {
      Get.back();
      _showSnackBar('Erro', 'Não foi possível alterar o idioma', isError: true);
    }
  }

  void _showSnackBar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF1B5E20),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryFuelColor.withOpacity(isDark ? 0.15 : 0.05)
            : (isDark ? AppTheme.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryFuelColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(language.flag, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          language.name,
          style: GoogleFonts.vazirmatn(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? AppTheme.primaryFuelColor
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          language.code.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryFuelColor,
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.disabledColor,
              ),
      ),
    );
  }
}
