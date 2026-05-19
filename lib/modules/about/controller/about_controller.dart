import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    try{
      isCheckingForUpdate.value = true;
      final data = await supabase.from('app_config').select('version, update_url').single().order('created_at', ascending: false);
      final String latestVersion = data['version'];
      final String updateUrl = data['update_url'];

      if(_isUpdateAvailable(appVersion.value, latestVersion)){
        _showUpdateDialog(latestVersion, updateUrl);
      }else{
        _showCustomSnackbar('up_check_title'.tr, 'up_no_updates'.tr, isError: true);
      }
    }catch(e){
      _showCustomSnackbar('up_error_title'.tr, 'Eror ao verificar atualização: $e', isError: true);
    }finally{
      isCheckingForUpdate.value = false;
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = current.split('.').map(int.parse).toList();

    for(int i = 0; i < latestParts.length; i++){
      if(latestParts[i] > currentParts[i]) return true;
      if(latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog(String newVersion, String url) {
    Get.defaultDialog(
      title: 'up_available_title'.tr,
      middleText: '${'up_available_desc'.tr} $newVersion',
      textConfirm: 'up_update_now'.tr,
      textCancel: 'up_later'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final uri = Uri.parse(url);
        if(await canLaunchUrl(uri)){
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        Get.back();
      },
    );
  }

  void _showCustomSnackbar(String title, String mensagem, {bool isError = false}){
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
      )
    );
  }

  void setChecking(bool value) {
    isCheckingForUpdate.value = value;
  }
}
