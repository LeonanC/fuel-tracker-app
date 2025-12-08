import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/models/services_type_model.dart';
import 'package:fuel_tracker_app/screens/maintenance_entry_screen.dart';
import 'package:get/get.dart';

class MaintenanceController extends GetxController {
  final FuelDb _db = FuelDb();
  
  var maintenanceEntries = <MaintenanceEntry>[].obs;
  var serviceType = <ServicesTypeModel>[].obs;
  var isLoading = false.obs;
  var lastOdometerFromDb = Rxn<double>();
  
  ServicesTypeModel? selectedServiceType;
  String serviceName = '';
  List<MaintenanceEntry> get loadedEntries => maintenanceEntries.toList();
  double get lastOdometer => lastOdometerFromDb.value ?? 0.0;

  @override
  void onInit(){
    loadMaintenanceEntries();
    super.onInit();
  }

  
  void navigateToAddEntry(BuildContext context, {MaintenanceEntry? data}) async {
    final currentOdometer = lastOdometer;

    final entry = await Get.to<MaintenanceEntry>(
      () => MaintenanceEntryScreen(lastOdometer: currentOdometer, entry: data),
    );

    if (entry != null) {
      await insertEntry(entry);
    }
  }

  Future<void> loadMaintenanceEntries() async {
    isLoading.value = true;
    

    final List<Map<String, dynamic>> maps = await _db.getAllMaintenanceEntries();
    final List<MaintenanceEntry> loadedEntries = maps.map((map) => MaintenanceEntry.fromMap(map)).toList();
    lastOdometerFromDb.value = await _db.getLastOdometer();
    loadedEntries.sort((a, b) => b.dataServico.compareTo(a.dataServico));
    maintenanceEntries.assignAll(loadedEntries);
    isLoading.value = false;
  }

  Future<void> insertEntry(MaintenanceEntry entry) async {
    await _db.insertMaintenance(entry.toMap());
    await loadMaintenanceEntries();
  }

  Future<void> updateEntry(MaintenanceEntry entry) async {
    if(entry.id == null) return;
    await _db.updateMaintenance(entry.toMap());
    await loadMaintenanceEntries();
  }

  Future<void> deleteEntry(int id) async {
    if(await _db.deleteMaintenance(id)){
      maintenanceEntries.removeWhere((entry) => entry.id == id);
    }
  }

  List<MaintenanceEntry> getActiveReminders(double currentOdometer){
    return maintenanceEntries.where((entry){
      if(!entry.lembreteAtivo){
        return false;
      }

      final bool datePassed = entry.lembreteData != null && entry.lembreteData!.isBefore(DateTime.now());
      final bool kmReached = entry.lembreteKm != null && currentOdometer >= entry.lembreteKm!;

      return datePassed || kmReached;
    }).toList();
  }
}