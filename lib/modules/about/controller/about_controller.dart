import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends GetxController {
  var appVersion = 'Carregando...'.obs;
  var isCheckingForUpdate = false.obs;

  @override
  void onInit() {
    _loadAppVersion();
    super.onInit();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = 'Erro ao carregar';
    }
  }

  void setCheckingForUpdate(bool value) {
    isCheckingForUpdate.value = value;
  }
}
