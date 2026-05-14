import 'package:fuel_tracker_app/modules/gas/controller/gasStation_controller.dart';
import 'package:get/get.dart';

class GasStationBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<GasStationController>(() => GasStationController(), fenix: true);
  }
}