import 'package:fuel_tracker_app/modules/welcome/loading_controller.dart';
import 'package:get/get.dart';

class LoadingBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<LoadingController>(() => LoadingController());
  }
}