import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/app_update.dart';
import 'package:fuel_tracker_app/data/services/update_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remixicon/remixicon.dart';

class UpdateController extends GetxController {
  final UpdateService _updateService = UpdateService();
  final _box = GetStorage();

  Rxn<AppUpdate> latestUpdate = Rxn<AppUpdate>();
  RxString installedVersion = '...'.obs;
  RxBool isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await getInstalledAppVersion();
    checkForUpdate(showNoUpdateMessage: false);
  }

  Future<void> getInstalledAppVersion() async {
    try {
      installedVersion.value = await _updateService.getInstalledAppVersion();
    } catch (e) {
      installedVersion.value = "0.0.0";
    }
  }

  Future<void> checkForUpdate({bool showNoUpdateMessage = false}) async {
    try {
      isChecking.value = true;
      final AppUpdate? latest = await _updateService.fetchLatestVersion();

      if (latest != null) {
        bool isNewer = _updateService.isNewerVersion(
          latest.version,
          installedVersion.value,
        );

        if (isNewer) {
          latestUpdate.value = latest;
          if (showNoUpdateMessage || _shouldShowDialog(latest.version)) {
            _showwUpdateDialog(latest);
          }
        } else if (showNoUpdateMessage) {
          _showNoUpdateSnackbar(isError: false);
        }
      }
    } catch (e) {
      if (showNoUpdateMessage) _showNoUpdateSnackbar(isError: true);
    } finally {
      isChecking.value = false;
    }
  }

  bool _shouldShowDialog(String version) {
    final lastIgnore = _box.read('ignore_version');
    return lastIgnore != version;
  }

  void _showwUpdateDialog(AppUpdate update) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF252525),
        title: Text(
          'Atualização Disponível!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão: ${update.version}',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(update.messText, style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _box.write('ignore_version', update.version);
              Get.back();
            },
            child: Text(
              "Mais Tarde",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              await _handleLaunchUrl(update.url.trim());
            },
            child: Text(
              "Atualizar Agora",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showNoUpdateSnackbar({required bool isError}) async {
    Get.snackbar(
      isError ? 'Erro' : 'App Atualizado',
      isError
          ? 'Não foi possível buscar atualizações'
          : 'Você já está usando a versão mais recente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent
          : Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      icon: Icon(
        isError
            ? RemixIcons.error_warning_line
            : RemixIcons.checkbox_circle_line,
        color: Colors.white,
      ),
    );
  }

  Future<void> _handleLaunchUrl(String url) async {
    if (url.isEmpty) return;

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
