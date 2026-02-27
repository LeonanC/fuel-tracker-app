import 'package:fuel_tracker_app/modules/fuel/controllers/backup_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/map_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/onboarding_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/theme_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/update_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(OnboardingController(), permanent: true);
    Get.put(CurrencyController(), permanent: true);
    Get.put(UnitController(), permanent: true);
    Get.put(LookupController(), permanent: true);
    Get.put(MaintenanceController(), permanent: true);
    Get.put(FuelListController(), permanent: true);
    Get.put(MapNavigationController(), permanent: true);
    Get.put(UpdateController(), permanent: true);
    Get.put(BackupController(), permanent: true);
  }
}
