import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  final FuelDb _db = FuelDb();

  final RxList<ServicesTypeModel> _serviceType = <ServicesTypeModel>[].obs;
  final RxBool _isLoading = false.obs;
  final Rxn<double> _lastOdometer = Rxn<double>();

  final Rxn<ServicesTypeModel> _selectedServiceType = Rxn<ServicesTypeModel>();
  final RxString _serviceName = ''.obs;

  List<ServicesTypeModel> get serviceType => _serviceType;
  bool get isLoading => _isLoading.value;
  double? get lastOdometer => _lastOdometer.value;
  ServicesTypeModel? get selectedServiceType => _selectedServiceType.value;
  String get serviceName => _serviceName.value;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final List<ServicesTypeModel> loadedServices = await _db.getServices();
      final odometer = await _db.getLastOdometer();
      serviceType.assignAll(loadedServices);
      _lastOdometer.value = odometer;

    } catch (e) {
      _showErrorSnackBar('Erro ao carregar', 'Não foi possível buscar os serviços no banco.');
    }
  }

  Future<void> saveService(ServicesTypeModel newService) async {
    try{
      _isLoading.value = true;
      await _db.insertServices(newService);
      _serviceType.add(newService);
      Get.back();
    }catch(e){
      _showErrorSnackBar('Erro ao salvar', 'Não foi possível salvar o novo serviço.');
    }finally{
      _isLoading.value = false;
    }
  }

  void _showErrorSnackBar(String title, String message){
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}
