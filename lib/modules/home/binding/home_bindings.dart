import 'package:fuel_tracker_app/data/controllers/app_controller.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/auth/completar_perfil_controller.dart';
import 'package:fuel_tracker_app/modules/auth/login_controller.dart';
import 'package:fuel_tracker_app/modules/backup/controller/backup_controller.dart';
import 'package:fuel_tracker_app/modules/gas/controller/gasStation_controller.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/maps/controller/map_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/registro/controller/home_entry_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:get/get.dart';

class HomeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppController>(() => AppController(), fenix: true);
    Get.lazyPut<LookupController>(() => LookupController(), fenix: true);
    Get.lazyPut<CurrencyController>(() => CurrencyController(), fenix: true);
    Get.lazyPut<GasStationController>(
      () => GasStationController(),
      fenix: true,
    );
    Get.lazyPut<VehicleController>(() => VehicleController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<CompletarPerfilController>(
      () => CompletarPerfilController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<HomeEntryController>(() => HomeEntryController(), fenix: true);
    Get.lazyPut<PerfilController>(() => PerfilController(), fenix: true);
    Get.lazyPut<SettingController>(() => SettingController(), fenix: true);
    Get.lazyPut<MapNavigationController>(
      () => MapNavigationController(),
      fenix: true,
    );
    
    Get.lazyPut<BackupController>(() => BackupController(), fenix: true);
  }
}
