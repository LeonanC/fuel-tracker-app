import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/lookup_controller.dart';
import 'package:get/get.dart';

class FuelBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LookupController>(() => LookupController(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController());
  }
}
