import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/gas/controller/gasStation_controller.dart';
import 'package:fuel_tracker_app/modules/login/controller/completar_perfil_controller.dart';
import 'package:get/get.dart';

class AppBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<LookupController>(() => LookupController());
  Get.lazyPut<CurrencyController>(() => CurrencyController());
  Get.lazyPut<GasStationController>(() => GasStationController());
  Get.lazyPut<CompletarPerfilController>(() => CompletarPerfilController());
  Get.lazyPut<LookupController>(() => LookupController());
  }
}