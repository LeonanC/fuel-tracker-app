import 'package:fuel_tracker_app/data/controllers/app_controller.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/about/controller/about_controller.dart';
import 'package:fuel_tracker_app/modules/backup/controller/backup_controller.dart';
import 'package:fuel_tracker_app/modules/gas/controller/station_controller.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/login/controller/login_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/station_entry_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/vehicle_entry_controller.dart';
import 'package:fuel_tracker_app/modules/remider/controller/reminder_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:fuel_tracker_app/modules/loading/loading_controller.dart';
import 'package:get/get.dart';

class AppBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<AppController>(() => AppController(), fenix: true);  
  Get.lazyPut<LoginController>(() => LoginController(), fenix: true);  
  Get.lazyPut<AboutController>(() => AboutController(), fenix: true);  
  Get.lazyPut<HomeController>(() => HomeController(), fenix: true);  
  Get.lazyPut<SettingController>(() => SettingController(), fenix: true);  
  Get.lazyPut<PerfilController>(() => PerfilController(), fenix: true);
  Get.lazyPut<ReminderController>(() => ReminderController(), fenix: true);
  Get.lazyPut<StationController>(() => StationController(), fenix: true);
  Get.lazyPut<BackupController>(() => BackupController(), fenix: true);

  Get.lazyPut<LoadingController>(() => LoadingController(), fenix: true);  
  Get.lazyPut<CurrencyController>(() => CurrencyController(), fenix: true);
  Get.lazyPut<LookupController>(() => LookupController(), fenix: true);
  Get.lazyPut<VehicleController>(() => VehicleController(), fenix: true);
  Get.lazyPut<HomeEntryController>(() => HomeEntryController(), fenix: true);
  Get.lazyPut<VehicleEntryController>(() => VehicleEntryController(), fenix: true);
  Get.lazyPut<StationEntryController>(() => StationEntryController(), fenix: true);
  
  }
}