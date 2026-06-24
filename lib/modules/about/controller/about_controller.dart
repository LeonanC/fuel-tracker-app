import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  final supabase = Supabase.instance.client;

  var appVersion = '10.4.0'.obs;
  var isCheckingForUpdate = false.obs;

  @override
  void onInit() {
    _loadAppVersion();
    super.onInit();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  Future<void> checkForUpdate() async {
    try {
      isCheckingForUpdate.value = true;
      final url = Uri.parse(
        'https://raw.githubusercontent.com/LeonanC/fuel-tracker-app/main/version.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        String latestGithubVersion = data['version'];
        latestGithubVersion = latestGithubVersion.replaceAll('v', '');
        final String updateUrl = data['url'];
        final String updateMessage = data['message'] ?? 'up_available_desc'.tr;

        await _syncVersionToSupabase(latestGithubVersion, updateUrl);

        if (_isUpdateAvailable(appVersion.value, latestGithubVersion)) {
          _showUpdateDialog(latestGithubVersion, updateUrl, updateMessage);
        } else {
          _showCustomSnackbar(
            'up_check_title'.tr,
            'up_no_updates'.tr,
            isError: true,
          );
        }
      } else {
        _showCustomSnackbar(
          'up_error_title'.tr,
          'Erro ao buscar dados do GitHub (${response.statusCode})',
        );
      }
    } catch (e) {
      _showCustomSnackbar(
        'up_error_title'.tr,
        'Eror ao verificar atualização: $e',
        isError: true,
      );
    } finally {
      isCheckingForUpdate.value = false;
    }
  }

  Future<void> _syncVersionToSupabase(String githubVersion, String url) async {
    try{
    final supabaseData = await supabase
        .from('app_config').select('id, version').order('created_at', ascending: false).limit(1).maybeSingle();

    if(supabaseData != null){
      final String currentSupabaseVersion = supabaseData['version'];
      final int rowId = supabaseData['id'];

      if(_isUpdateAvailable(currentSupabaseVersion, githubVersion)){
        await supabase.from('app_config').update({
          'version': githubVersion,
          'update_url': url,
          'update_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', rowId);
      }
    } else {
      await supabase.from('app_config').insert({
        'version': githubVersion,
        'update_url': url,
        'required': false,
      });
    }
    }catch(e){
      debugPrint("Erro ao sincronizar com o Supabase: $e");
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    int maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (int i = 0; i < maxLength; i++) {
      int currentVersionPart = i < currentParts.length ? currentParts[i] : 0;
      int latestVersionPart = i < latestParts.length ? latestParts[i] : 0;

      if (latestVersionPart > currentVersionPart) return true;
      if (latestVersionPart < currentVersionPart) return false;
    }
    return false;
  }

  void _showUpdateDialog(String newVersion, String url, String message) {
    Get.defaultDialog(
      title: 'up_available_title'.tr,
      middleText: '${'up_available_desc'.tr} $newVersion',
      textConfirm: 'up_update_now'.tr,
      textCancel: 'up_later'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Get.back();
      },
    );
  }

  void _showCustomSnackbar(
    String title,
    String mensagem, {
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      mensagem,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.8)
          : Colors.greenAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: Icon(
        isError ? RemixIcons.error_warning_line : RemixIcons.check_line,
        color: Colors.white,
      ),
    );
  }

  void setChecking(bool value) {
    isCheckingForUpdate.value = value;
  }
}
