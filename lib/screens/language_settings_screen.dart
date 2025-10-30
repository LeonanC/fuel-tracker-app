import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_language.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHigh;
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isRtlLanguage =
            languageProvider.currentLanguage.code == 'en' ||
            languageProvider.currentLanguage.code == 'pt';

        final titleStyle = isRtlLanguage
            ? GoogleFonts.vazirmatn(color: primaryTextColor, fontWeight: FontWeight.bold)
            : theme.appBarTheme.titleTextStyle?.copyWith(color: primaryTextColor);
        final subtitleStyle = isRtlLanguage
            ? GoogleFonts.vazirmatn(fontSize: 16, color: secondaryTextColor)
            : theme.textTheme.titleMedium?.copyWith(color: secondaryTextColor);
            
        final sectionTextStyle = isRtlLanguage
            ? GoogleFonts.vazirmatn(fontSize: 18, color: primaryTextColor, fontWeight: FontWeight.bold)
            : theme.textTheme.titleLarge?.copyWith(fontSize: 18, color: primaryTextColor, fontWeight: FontWeight.bold);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
            appBar: AppBar(
              backgroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
              title: Text(
                languageProvider.translate('language_settings.title'),
                style: titleStyle,
              ),
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
                        Text(
                          languageProvider.translate(
                            'language_settings.subtitle',
                          ),
                          style: subtitleStyle,
                        ),
                        const SizedBox(height: 24),
                        _buildCurrentLanguageCard(
                          languageProvider,
                          isRtlLanguage,
                          primaryTextColor,
                          secondaryTextColor,
                          cardColor,
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
                            languageProvider.translate(
                              'language_settings.available_languages',
                            ),
                            style: sectionTextStyle,
                          ),
                          Expanded(
                            child: _buildLanguageList(
                              languageProvider,
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
          ),
        );
      },
    );
  }

  Widget _buildCurrentLanguageCard(
    LanguageProvider languageProvider,
    bool isRtlLanguage,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    final languageNameStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 18,
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          )
        : TextStyle(
            fontSize: 18,
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          );
    final languageCodeStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(fontSize: 14, color: secondaryTextColor)
        : TextStyle(fontSize: 14, color: secondaryTextColor);

    final currentlanguageLabelStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 14,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryFuelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryFuelColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate('language_settings.current_language'),
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
                child: Text(
                  languageProvider.currentLanguage.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.currentLanguage.name,
                    style: languageNameStyle.copyWith(color: AppTheme.textLight),
                  ),
                  Text(
                    languageProvider.currentLanguage.code.toUpperCase(),
                    style: languageCodeStyle.copyWith(color: AppTheme.textLight.withOpacity(0.8)),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: AppTheme.textLight,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList(
    LanguageProvider languageProvider,
    bool isRtlLanguage,
    Color primaryTextColor,
    Color cardColor,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: AppLanguage.supportedLanguages.length,
      itemBuilder: (context, index) {
        final language = AppLanguage.supportedLanguages[index];
        final isSelected = language == languageProvider.currentLanguage;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: _buildLanguageCard(
            language,
            isSelected,
            languageProvider,
            index,
            isRtlLanguage,
            primaryTextColor,
            cardColor,
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(
    AppLanguage language,
    bool isSelected,
    LanguageProvider languageProvider,
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
    final directionStyle = isRtlLanguage
        ? GoogleFonts.vazirmatn(
            fontSize: 10,
            color: language.isRtl ? Colors.orange : Colors.blue,
            fontWeight: FontWeight.w600,
          )
        : TextStyle(
            fontSize: 10,
            color: language.isRtl ? Colors.orange : Colors.blue,
            fontWeight: FontWeight.w600,
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
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.1)
                  : cardColor,
                  
              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? selectedColor.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: isSelected
                    ? null
                    : () =>
                          _changeLanguage(context, language, languageProvider),
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
                        child: Text(
                          language.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
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
                                Text(
                                  language.code.toUpperCase(),
                                  style: languageCodeStyle,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: language.isRtl
                                        ? Colors.orange.withValues(alpha: 0.2)
                                        : Colors.blue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    language.direction.toUpperCase(),
                                    style: directionStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.textGrey,
                          size: 16,
                        ),
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

  Future<void> _changeLanguage(
    BuildContext context,
    AppLanguage language,
    LanguageProvider languageProvider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryFuelColor),
        ),
      ),
    );
    try {
      final success = await languageProvider.changeLanguage(language);
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          _showSuccessMessage(context, languageProvider);
        } else {
          // ErrorSnackbar.show(
          //   context,
          //   'Failed to change language. Please try again',
          // );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        // ErrorSnackbar.show(
        //   context,
        //   'An error occurrend while changing language.',
        // );
      }
    }
  }

  void _showSuccessMessage(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('language_settings.language_changed'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              languageProvider.translate('language_settings.restart_required'),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 5, 83, 46),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: languageProvider.translate('common_labels.ok'),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
