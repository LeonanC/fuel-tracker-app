import 'package:fuel_tracker_app/modules/about/controller/about_controller.dart';
import 'package:get/get.dart';

class AboutBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<AboutController>(() => AboutController(), fenix: true);
  }
}