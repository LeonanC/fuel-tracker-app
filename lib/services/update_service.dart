import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class UpdateService {
  static const String updateUrl =
      'https://raw.githubusercontent.com/LeonanC/fuel-tracker-app/main/config/update.json';

  Future<AppUpdate?> fetchLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(updateUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AppUpdate.fromJson(json);
      } else {
        debugPrint('Falha ao carregar atualização. Código de status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro de rede ao buscar atualização: $e');
      return null;
    }
  }

  Future<String> getInstalledAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> checkForUpdate(BuildContext context) async {
    final installedVersion = await getInstalledAppVersion();
    final latestUpdate = await fetchLatestVersion();
    print(installedVersion);
    if (latestUpdate != null) {
      final latestVersion = latestUpdate.version;
      if (isNewerVersion(latestVersion, installedVersion)) {
        showUpdateDialog(context, latestUpdate);
      } else {
        print('Versão Instalada: $installedVersion. Versão do Servidor: ${latestUpdate.version}.');
      }
    }
  }

  bool isNewerVersion(String latest, String installed){
    return latest.compareTo(installed) > 0;
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível iniciar: $url');
    }
  }

  void showUpdateDialog(BuildContext context, AppUpdate update) async {
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr(TranslationKeys.updateServiceLater)),
            ),
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

  Future<void> checkAppUpdate(BuildContext context) async {
    final versionLabel = context.tr(TranslationKeys.updateServiceCurrentVersion);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final fullVersionText = '$versionLabel ${packageInfo.version}';
    final AppUpdate? latestUpdate = await fetchLatestVersion();

    if (latestUpdate == null) {
      return;
    }

    final String currentVersionString = await getInstalledAppVersion();

    try {
      final currentVersion = Version.parse(currentVersionString);
      final latestVersion = Version.parse(latestUpdate.version);

      if (latestVersion > currentVersion) {
        showUpdateDialog(context, latestUpdate);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fullVersionText), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(TranslationKeys.updateServiceNoUpdate)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
