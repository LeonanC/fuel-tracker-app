import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/about_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/update_controller.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final UpdateController updateController = Get.put(UpdateController());
  final AboutController aboutController = Get.put(AboutController());
  final LanguageController languageController = Get.find<LanguageController>();

  Future<void> _checkForUpdate(BuildContext context) async{
    await updateController.checkForUpdate();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'TranslationKeys.errorTitle',
        'TranslationKeys.errorTitle',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      final TextDirection textDirection = languageController.textDirection;

      return Directionality(textDirection: textDirection, child: _buildAboutScreen(context, theme));
    });
  }

  Widget _buildAboutScreen(BuildContext context, ThemeData theme) {
    return Obx(() {
      final versionLabel = context.tr(TranslationKeys.aboutCurrentVersion);
      final fullVersionText = '$versionLabel ${aboutController.appVersion.value}';
      final isChecking = aboutController.isCheckingForUpdate.value;

      return Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        appBar: AppBar(
          title: Text(context.tr(TranslationKeys.aboutTitle)),
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          foregroundColor: theme.colorScheme.onBackground,
          elevation: theme.appBarTheme.elevation,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Image.asset('assets/app_icon/icon.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fuel Tracker',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(fullVersionText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                context.tr(TranslationKeys.aboutTagline),
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                context.tr(TranslationKeys.aboutDevelopedBy),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(TranslationKeys.aboutDeveloper),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.backgroundColorDark
                      : AppTheme.backgroundColorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  context.tr(TranslationKeys.aboutDescription),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isChecking ? null : () => _checkForUpdate(context),
                  icon: isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_download),
                  label: Text(context.tr(TranslationKeys.updateServiceCheckForUpdates)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchUrl('https://github.com/LeonanC/fuel-tracker-app');
                  },
                  icon: const Icon(Icons.code),
                  label: Text(context.tr(TranslationKeys.aboutGithubSource)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchUrl('https://github.com/LeonanC/fuel-tracker-app/blob/main/privacy.md');
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(context.tr(TranslationKeys.aboutPrivacyPolicy)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchUrl('https://github.com/LeonanC/fuel-tracker-app/blob/main/terms.md');
                  },
                  icon: const Icon(Icons.gavel_outlined),
                  label: Text(context.tr(TranslationKeys.aboutTermsOfService)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                context.tr(TranslationKeys.aboutCopyright),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
