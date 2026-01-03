import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/screens/vehicle_entry_screen.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class VehicleController extends GetxController {
  var vehicles = <VehicleModel>[].obs;
  var fuelTypes = <TypeGasModel>[].obs;

  final FuelDb _db = FuelDb();

  VehicleModel? selectedVehicle;
  String vehicleName = '';

  @override
  void onInit() {
    loadVehicles();
    loadFuelTypes();
    super.onInit();
  }

  void navigateToAddEntry(BuildContext context, {VehicleModel? data}) async {
    final entry = await Get.to(() => VehicleEntryScreen(data: data));
    if(entry != null){
      await saveVehicle(entry);
    }
  }

  Future<void> loadVehicles() async {
    try {
      final List<VehicleModel> loadedVehicles = await _db.getVehicles();
      vehicles.assignAll(loadedVehicles);
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
    }
  }

  Future<void> loadFuelTypes() async {
    final List<TypeGasModel> data = await _db.getGas();
    fuelTypes.assignAll(data);
  }

  Future<void> loadNameVehicles(String value) async {
    if (value.isEmpty) {
      vehicleName = value;
      selectedVehicle = null;
      return;
    }
    vehicleName = value;

    try {
      final List<VehicleModel> results = await _db.getNamesPerVehicles(value);
      vehicles.assignAll(results);
    } catch (e) {
      print('Erro ao carregar veículos do banco de dados: $e');
      selectedVehicle = null;
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os veículos.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveVehicle(Map<String, dynamic> data) async {
    final db = await _db.getDb();
    if(data['pk_vehicle'] == null){
      await db.insert('vehicles', data);
    }else{
      await db.update('vehicles', data, where: 'pk_vehicle = ?', whereArgs: [data['pk_vehicle']]);
    }
    await loadVehicles();
  }

  void deleteVehicle(int id) async {
    await _db.deleteVehicle(id);
    await loadVehicles();

    Get.snackbar('Excluído', 'Veículo removido com sucesso.', snackPosition: SnackPosition.BOTTOM);
  }
}
