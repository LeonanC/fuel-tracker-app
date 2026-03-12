import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/app_language.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsScreen extends GetView<LanguageController> {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, theme, bgColor),
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) =>
            Opacity(opacity: value, child: child),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [_buildHeader(context, theme), _buildLanguageList()],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    Color bgColor,
  ) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      title: Obx(
        () => Text(
          context.tr('language_settings.title'),
          style: _getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final isRtl = controller.currentLanguage.isRtl;
    return isRtl
        ? GoogleFonts.vazirmatn(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          )
        : GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                context.tr('language_settings.subtitle'),
                style: _getTextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const _CurrentLanguageCard(),
            const SizedBox(height: 32),
            Obx(
              () => Text(
                context.tr('language_settings.available_languages'),
                style: _getTextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final language = AppLanguage.supportedLanguages[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Obx(() {
              final isSelected = language == controller.currentLanguage;
              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => _changeLanguage(context, language),
              );
            }),
          );
        }, childCount: AppLanguage.supportedLanguages.length),
      ),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    AppLanguage language,
  ) async {
    if (language == controller.currentLanguage) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator(strokeWidth: 3)),
      barrierDismissible: false,
    );

    try {
      final success = await controller.changeLanguage(language);
      Get.back();

      if (success) {
        _showSuccessSnackBar(context);
      }
    } catch (e) {
      Get.back();
      _showErrorSnackBar();
    }
  }

  void _showSuccessSnackBar(BuildContext context) {
    Get.snackbar(
      context.tr('language_settings.language_changed'),
      context.tr('language_settings.restart_required'),
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.done_all, color: Colors.white),
    );
  }

  void _showErrorSnackBar() {
    Get.snackbar(
      'Ops!',
      'Erro ao alterar idioma',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _CurrentLanguageCard extends GetView<LanguageController> {
  const _CurrentLanguageCard();

  @override
  Widget build(BuildContext context) {
    final lang = controller.currentLanguage;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(lang.flag, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context
                      .tr('language_settings.current_language')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  lang.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppTheme.primaryFuelColor.withOpacity(0.1)
              : theme.cardColor,
          border: Border.all(
            color: isSelected ? AppTheme.primaryFuelColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryFuelColor
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),

            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryFuelColor)
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.dividerColor,
              ),
          ],
        ),
      ),
    );
  }
}
