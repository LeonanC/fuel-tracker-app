import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/services/update_service.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';

class UpdateController extends GetxController {
  final UpdateService _updateService = UpdateService();
  Rxn<AppUpdate> latestUpdate = Rxn<AppUpdate>();
  RxString installedVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getInstalledAppVersion();
  }

  Future<void> getInstalledAppVersion() async {
    installedVersion.value = await _updateService.getInstalledAppVersion();
  }

  Future<void> checkForUpdate({bool showNoUpdateMessage = false}) async {
    final AppUpdate? latest = await _updateService.fetchLatestVersion();

    if (latest != null && _updateService.isNewerVersion(latest.version, installedVersion.value)) {
      latestUpdate.value = latest;
      _showUpdateDialog(latest);
    } else {
      latestUpdate.value = null;
      if (showNoUpdateMessage) {
        _showNoUpdateMessage(latest);
      }
    }
  }

  void _showUpdateDialog(AppUpdate update) async {
    final versionLabel = TranslationKeys.updateServiceNewVersion.tr;
    final fullVersionText = '$versionLabel ${update.version}';

    Get.dialog(
      AlertDialog(
        title: Text(TranslationKeys.updateServiceUpdateAvailable.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullVersionText),
            const SizedBox(height: 8),
            Text(update.messText, style: Get.textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TranslationKeys.updateServiceLater.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _handleLaunchUrl(update.url.trim());
            },
            child: Text(TranslationKeys.updateServiceDownload.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showNoUpdateMessage(AppUpdate? latest) async {
    if (latest != null) {
      final versionLabel = TranslationKeys.updateServiceCurrentVersion.tr;
      final fullVersionText = '$versionLabel ${installedVersion.value}';

      Get.snackbar(
        TranslationKeys.updateServiceUpdateAvailable.tr,
        fullVersionText,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Erro'.tr,
        TranslationKeys.updateServiceNoUpdate.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _handleLaunchUrl(String url) async {
    try {
      await _updateService.launchUrl(url);
    } catch (e) {
      Get.snackbar(
        'Erro'.tr,
        TranslationKeys.updateServiceUrlError.trParams({'url': url}),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
