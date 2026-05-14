import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';

class SettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerfilController>(() => PerfilController(), fenix: true);
    Get.lazyPut<SettingController>(() => SettingController(), fenix: true);
  }
}
