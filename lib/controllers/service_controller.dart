import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/screens/maintenance_entry_screen.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ServiceController extends GetxController {
  final FuelDb _db = FuelDb();

  static const double _lastOdometer = 0.0;

  var serviceType = <ServicesTypeModel>[].obs;
  var isLoading = false.obs;
  var lastOdometer = Rxn<double>();

  ServicesTypeModel? selectedServiceType;
  String serviceName = '';

  @override
  void onInit() {
    loadServices();
    super.onInit();
  }

  Future<void> loadServices() async {
    try {
      final List<ServicesTypeModel> loadedServices = await _db.getServices();
      lastOdometer.value = await _db.getLastOdometer();
      serviceType.assignAll(loadedServices);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os serviços.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void saveService(ServicesTypeModel newService) async {
    final serviceToSave = newService.id.isEmpty
        ? newService.copyWith(id: const Uuid().v4())
        : newService;

    await _db.insertServices(serviceToSave);
    await loadServices();
  }
}
