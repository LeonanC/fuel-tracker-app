import 'package:fuel_tracker_app/data/controllers/app_controller.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
import 'package:get/get.dart';

class AppBinding implements Bindings {
@override
void dependencies() {
  Get.put(AppController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(SettingController(), permanent: true);
  Get.put(PerfilController(), permanent: true);

  Get.lazyPut<LoadingController>(() => LoadingController(), fenix: true);  
  Get.lazyPut<VehicleController>(() => VehicleController(), fenix: true);
  Get.lazyPut<HomeEntryController>(() => HomeEntryController(), fenix: true);
  
  }
}