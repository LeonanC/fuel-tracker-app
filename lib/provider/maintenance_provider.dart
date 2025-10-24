import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/fuelentry_db.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';

class MaintenanceProvider with ChangeNotifier {
  final FuelEntryDb _db = FuelEntryDb();
  List<MaintenanceEntry> _maintenanceEntries = [];
  bool _isLoading = false;

  List<MaintenanceEntry> get maintenanceEntries => _maintenanceEntries;
  bool get isLoading => _isLoading;

  Future<void> loadMaintenanceEntries() async {
    _isLoading = true;
    notifyListeners();

    final List<Map<String, dynamic>> maps = await _db.getAllMaintenanceEntries();
    _maintenanceEntries = maps.map((map) => MaintenanceEntry.fromMap(map)).toList();
    _maintenanceEntries.sort((a, b) => b.dataServico.compareTo(a.dataServico));
    _isLoading = false;
    notifyListeners();
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
      _maintenanceEntries.removeWhere((entry) => entry.id == id);
      notifyListeners();
    }
  }

  List<MaintenanceEntry> getActiveReminders(double currentOdometer){
    return _maintenanceEntries.where((entry){
      if(!entry.lembreteAtivo){
        return false;
      }

      final bool datePassed = entry.lembreteData != null && entry.lembreteData!.isBefore(DateTime.now());
      final bool kmReached = entry.lembreteKm != null && currentOdometer >= entry.lembreteKm!;

      return datePassed || kmReached;
    }).toList();
  }
}