import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/app_update.dart';
import 'package:fuel_tracker_app/data/services/update_service.dart';
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

    if (latest != null &&
        _updateService.isNewerVersion(latest.version, installedVersion.value)) {
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
    final fullVersionText = 'Nova Versão: ${update.version}';

    Get.dialog(
      AlertDialog(
        title: Text('Atualização Disponível!'),
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
          TextButton(onPressed: () => Get.back(), child: Text("Mais Tarde")),
          TextButton(
            onPressed: () async {
              Get.back();
              await _handleLaunchUrl(update.url.trim());
            },
            child: Text("Baixar Agora"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showNoUpdateMessage(AppUpdate? latest) async {
    if (latest != null) {
      final fullVersionText = 'Sua Versão: ${installedVersion.value}';

      Get.snackbar(
        'Atualização Disponível!',
        fullVersionText,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Erro'.tr,
        'Nenhuma atualização encontrada.',
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
        'Não foi possível abrir a URL: $url. Por favor, verique se o link está correto.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
