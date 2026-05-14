import 'package:fuel_tracker_app/data/controllers/app_controller.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
import 'package:get/get.dart';

class LoadingBinding implements Bindings {
@override
void dependencies() {
  Get.put(AppController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.lazyPut<LoadingController>(() => LoadingController(), fenix: true);
  
  }
}