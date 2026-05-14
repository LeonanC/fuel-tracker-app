import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:get/get.dart';

class VehicleBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<VehicleController>(() => VehicleController(), fenix: true);
  }
}