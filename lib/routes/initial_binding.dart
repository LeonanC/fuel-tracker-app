import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/controllers/map_controller.dart';
import 'package:fuel_tracker_app/controllers/onboarding_controller.dart';
import 'package:fuel_tracker_app/controllers/service_controller.dart';
import 'package:fuel_tracker_app/controllers/type_gas_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/update_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies(){    
    Get.put(OnboardingController(), permanent: true);
    Get.put(CurrencyController(), permanent: true);
    Get.put(UnitController(), permanent: true);
    Get.put(TypeGasController(), permanent: true);
    Get.put(ServiceController(), permanent: true);
    Get.put(VehicleController(), permanent: true);
    Get.put(GasStationController(), permanent: true);
    Get.put(MaintenanceController(), permanent: true);
    Get.put(FuelListController(), permanent: true);
    Get.put(MapNavigationController(), permanent: true);
    Get.put(UpdateController(), permanent: true);
    
   

    
  }
}