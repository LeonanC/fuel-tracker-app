import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String updateUrl = 'https://raw.githubusercontent.com/LeonanC/fuel-tracker-app/main/config/update.json';
  Future<AppUpdate?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(updateUrl));
      if (response.statusCode == 200) {
        final AppUpdate? update = AppUpdate.fromJsonString(response.body);
        if (update != null && update.hasUpdate()) {
          return update;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  void showUpdateDialog(BuildContext context, AppUpdate update) {
    final versionLabel = context.tr(TranslationKeys.updateServiceNewVersion);
    final fullVersionText = '$versionLabel ${update.version}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.updateServiceUpdateAvailable)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullVersionText),
              const SizedBox(height: 8),
              Text(update.messText, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr(TranslationKeys.updateServiceLater))),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _launchUrl(update.url.trim());
              },
              child: Text(context.tr(TranslationKeys.updateServiceDownload)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch: $url');
    }
  }
}
