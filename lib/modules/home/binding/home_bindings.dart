import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SettingController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.lazyPut<HomeEntryController>(() => HomeEntryController(), fenix: true);
  }
}
