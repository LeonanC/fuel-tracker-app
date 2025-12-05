import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:version/version.dart';

class UpdateService {
  final LanguageController languageController = Get.find<LanguageController>();
  
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

  bool isNewerVersion(String latest, String installed){
    try{
      final latestVersion = Version.parse(latest);
      final installedVersion = Version.parse(installed);
      return latestVersion > installedVersion;
    }catch(e){
      debugPrint('Erro ao comparar versões. Verifique se as strings são válidas: $e');
      return false;
    }
  }

  Future<void> launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try{
      if (!await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication)) {
        throw Exception('Não foi possível iniciar: $url');
      }
    }catch(e){
      throw Exception('Falha ao tentar abrir URL: $e');
    }
  }
}
