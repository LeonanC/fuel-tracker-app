import 'package:fuel_tracker_app/modules/remider/controller/reminder_controller.dart';
import 'package:get/get.dart';

class ReminderBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<ReminderController>(() => ReminderController(), fenix: true);
  }
}