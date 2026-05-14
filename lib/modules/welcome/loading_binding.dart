import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
import 'package:get/get.dart';

class LoadingBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<HomeController>(() => HomeController());
  Get.lazyPut<SettingController>(() => SettingController());
  Get.lazyPut<LoadingController>(() => LoadingController());
  
  }
}