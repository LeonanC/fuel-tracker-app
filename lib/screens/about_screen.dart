import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _){
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: _buildAboutScreen(context),
        );
      }
    );
  }

  Widget _buildAboutScreen(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.aboutTitle)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset('assets/app_icon/icon.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fuel Tracker',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(TranslationKeys.aboutVersion, parameters: {'version': '3.5.0'}),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
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
                color: Theme.of(context).colorScheme.surface,
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
                onPressed: (){
                  
                },
                icon: const Icon(Icons.telegram),
                label: Text(context.tr(TranslationKeys.aboutTelegramChannel)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0088cc),
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
                onPressed: (){
                  // _launchUrl('https://github.com/LeonanC/fuel-tracker-app');
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
                onPressed: (){
                  // _launchUrl('https://github.com/LeonanC/fuel-tracker-app');
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
                onPressed: (){
                  // _launchUrl('https://github.com/LeonanC/fuel-tracker-app');
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
  }
}