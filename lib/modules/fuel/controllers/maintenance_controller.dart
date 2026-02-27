import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/maintenance_entry_screen.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class MaintenanceController extends GetxController {
  final FuelDb _db = FuelDb();

  static const double _lastOdometer = 0.0;

  var maintenanceEntries = <MaintenanceEntry>[].obs;
  var isLoading = false.obs;
  var lastOdometer = Rxn<double>();

  List<MaintenanceEntry> get loadedEntries => maintenanceEntries.toList();

  @override
  void onInit() {
    loadMaintenanceEntries();
    super.onInit();
  }

  Future<void> loadMaintenanceEntries() async {
    isLoading.value = true;

    final List<Map<String, dynamic>> maps = await _db
        .getAllMaintenanceEntries();
    final List<MaintenanceEntry> loadedEntries = maps
        .map((map) => MaintenanceEntry.fromMap(map))
        .toList();
    // lastOdometer.value = await _db.getLastOdometer();
    loadedEntries.sort((a, b) => b.dataServico.compareTo(a.dataServico));
    maintenanceEntries.assignAll(loadedEntries);
    isLoading.value = false;
  }

  void navigateToAddEntry(
    BuildContext context, {
    MaintenanceEntry? data,
  }) async {
    final currentOdometer = lastOdometer.value;
    await Get.to(
      () => MaintenanceEntryScreen(lastOdometer: currentOdometer, entry: data),
    );
  }

  Future<void> saveMaintenance(MaintenanceEntry newMaintenance) async {
    await _db.insertMaintenance(newMaintenance);
    await loadMaintenanceEntries();
  }

  Future<void> deleteMaintenance(int id) async {
    await _db.deleteMaintenance(id);
    await loadMaintenanceEntries();
  }

  List<MaintenanceEntry> getActiveReminders(double currentOdometer) {
    return maintenanceEntries.where((entry) {
      if (!entry.lembreteAtivo) {
        return false;
      }

      final bool datePassed =
          entry.lembreteData != null &&
          entry.lembreteData!.isBefore(DateTime.now());
      final bool kmReached =
          entry.lembreteKm != null && currentOdometer >= entry.lembreteKm!;

      return datePassed || kmReached;
    }).toList();
  }
}
