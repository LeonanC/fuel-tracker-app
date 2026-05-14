import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:get/get.dart';

class PerfilBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<PerfilController>(() => PerfilController(), fenix: true);
  }
}