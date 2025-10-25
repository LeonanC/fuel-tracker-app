import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/services/update_service.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = 'Carregando...';
  final UpdateService _updateService = UpdateService();
  bool _isCheckingForUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Erro ao carregar';
        });
      }
    }
  }

  Future<void> _checkForUpdate() async {
    if(_isCheckingForUpdate) return;
    setState(() {
      _isCheckingForUpdate = true;
    });

    try{
      await _updateService.checkAppUpdate(context);

    }catch(e){
      debugPrint('Erro durante a checagem de atualização: $e');
    }finally{
      if(mounted){
        setState(() {
          _isCheckingForUpdate = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Directionality(textDirection: languageProvider.textDirection, child: _buildAboutScreen(context));
      },
    );
  }

  Widget _buildAboutScreen(BuildContext context) {
    final versionLabel = context.tr(TranslationKeys.aboutCurrentVersion);
    final fullVersionText = '$versionLabel $_appVersion';
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(TranslationKeys.aboutTitle)), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
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
            const Text('Fuel Tracker', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(fullVersionText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              context.tr(TranslationKeys.aboutTagline),
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(context.tr(TranslationKeys.aboutDevelopedBy), style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(context.tr(TranslationKeys.aboutDeveloper), style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Text(context.tr(TranslationKeys.aboutDescription), style: const TextStyle(fontSize: 16, height: 1.5)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCheckingForUpdate ? null : () => _checkForUpdate(),
                icon: _isCheckingForUpdate ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_download),
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
  }
}
