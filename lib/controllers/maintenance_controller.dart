import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/maintenance_entry_model.dart';
import 'package:get/get.dart';

class MaintenanceController extends GetxController {
  final FuelDb _db = FuelDb();
  
  var _maintenanceEntries = <MaintenanceEntry>[].obs;
  var isLoading = false.obs;
  var lastOdometerFromDb = Rxn<double>();
  final LanguageController languageController = Get.find<LanguageController>();

  List<MaintenanceEntry> get loadedEntries => _maintenanceEntries.toList();
  double get lastOdometer => lastOdometerFromDb.value ?? 0.0;

  @override
  void onInit(){
    loadMaintenanceEntries();
    super.onInit();
  }

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
  }

  Future<void> loadMaintenanceEntries() async {
    isLoading.value = true;
    

    final List<Map<String, dynamic>> maps = await _db.getAllMaintenanceEntries();
    final List<MaintenanceEntry> loadedEntries = maps.map((map) => MaintenanceEntry.fromMap(map)).toList();
    lastOdometerFromDb.value = await _db.getLastOdometer();
    loadedEntries.sort((a, b) => b.dataServico.compareTo(a.dataServico));
    _maintenanceEntries.assignAll(loadedEntries);
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
      _maintenanceEntries.removeWhere((entry) => entry.id == id);
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