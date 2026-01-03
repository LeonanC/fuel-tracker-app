import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/type_gas_model.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:fuel_tracker_app/repository/fuel_repository.dart';
import 'package:fuel_tracker_app/screens/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';

class FuelListController extends GetxController {
  var fuelEntries = <FuelEntryModel>[].obs;
  var fuelTypeEntries = <TypeGasModel>[].obs;
  var vehicleEntries = <VehicleModel>[].obs;
  var gasStationEntries = <GasStationModel>[].obs;

  final FuelDb _db = FuelDb();

  static const double _alertThresholdKm = 100.0;
  static const double _kmToMileFactor = 0.621371;
  static const double _kmPerLiterToMPGFactor = 2.3521458;

  final UnitController unitController = Get.find<UnitController>();
  final VehicleController vehicleController = Get.find();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final sucessoMessage = ''.obs;

  
  var lastOdometer = Rxn<double>();
  var overallConsumption = 0.0.obs;
  
  var selectedVehicleFilter = Rxn<String>();
  var selectedFuelTypeFilter = Rxn<String>();
  var selectedStationFilter = Rxn<String>();

   @override
  void onInit() {
    refreshAllData();
    super.onInit();
  }

  Future<void> refreshAllData() async {
    isLoading.value = true;
    await Future.wait([
      loadFuel(),
      loadTypeFuel(),
      loadVehicle(),
      loadStation(),
    ]);
    isLoading.value = false;
  }

  VehicleModel? get selectedVehicleData {
    if(selectedVehicleFilter.value == null) return null;
    return vehicleEntries.firstWhereOrNull(
      (v) => v.nickname == selectedVehicleFilter.value,
    );
  }
  
  Future<void> loadFuel() async {
    try {
      errorMessage.value = '';
      final List<FuelEntryModel> entries = await _db.getFuel();
      final double odometerValue = await _db.getLastOdometer();

      entries.sort((a, b) => b.entryDate.compareTo(a.entryDate));
      fuelEntries.assignAll(entries);

      final Map<String, dynamic> consumptionData = calculateOverallAverageConsumption(
        entries: entries,
      );

      overallConsumption.value = consumptionData['overall'] as double;
      lastOdometer.value = odometerValue;
    } catch (e) {
      errorMessage.value = 'Não foi possível carregar os dados. Verifique sua conexão.';
    }
  }

  Future<void> loadTypeFuel() async =>  fuelTypeEntries.assignAll(await _db.getGas());
  Future<void> loadVehicle() async => vehicleEntries.assignAll(await _db.getVehicles());
  Future<void> loadStation() async => gasStationEntries.assignAll(await _db.getStation());

  Future<void> saveFuel(Map<String, dynamic> data) async {
    final db = await _db.getDb();
    if(data['pk_fuel'] == null){
      await db.insert('fuel_entries', data);  
    }else{
      await db.update('fuel_entries', data, where: 'pk_fuel = ?', whereArgs: [data['pk_fuel']]);
    }
    await loadFuel();
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteFuelEntrie(id);
    await loadFuel();
  }

  List<FuelEntryModel> get filteredEntries {
    return fuelEntries.where((entry) {
      bool matchesVehicle =
          selectedVehicleFilter.value == null || entry.vehicleName == selectedVehicleFilter.value;
      bool matchesFuelType =
          selectedFuelTypeFilter.value == null || entry.fuelTypeName == selectedFuelTypeFilter.value;
      bool matchesStation =
          selectedStationFilter.value == null || entry.stationName == selectedStationFilter.value;
      return matchesVehicle && matchesFuelType && matchesStation;
    }).toList();
  }

  void setVeiculoFilter(String? vehicle) {
    selectedVehicleFilter.value = vehicle;
  }

  void setFuelTypeFilter(String? type) {
    selectedFuelTypeFilter.value = type;
  }

  void setStationFilter(String? station) {
    selectedStationFilter.value = station;
  }

  Map<String, String>? get fuelAlertData {
    final entries = filteredEntries;

    final double tankSize = selectedVehicleData?.tankCapacity ?? (vehicleEntries.isNotEmpty ? vehicleEntries.first.tankCapacity : 0.0);

    if (entries.length < 2 || overallConsumption <= 0 || tankSize <= 0) {
      return null;
    }

    final lastEntry = entries.first;
    final previousEntry = entries[1];

    final distanceSinceLastFill = lastEntry.odometerKm - previousEntry.odometerKm;
    final double avgConsump = overallConsumption.value;

    final double totalEstimatedRange = tankSize * avgConsump;
    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final bool isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
      final double rangeToDisplay = isMiles ? (estimatedRange * _kmToMileFactor) : estimatedRange;

      final String distUnit = getDistanceUnitString();
      final String consUnit = getConsumptionUnitString();
      final String displayRange = rangeToDisplay.toStringAsFixed(0);

      final double trajetConsump = distanceSinceLastFill / lastEntry.volumeLiters;

      return {
        'alertText': 'Autonomia restante: $displayRange $distUnit Consumo no trajeto: ${formatConsumption(trajetConsump)} $consUnit',
        'displayRange': displayRange,
        'distanceUnit': distUnit,
        'consumptionValue': formatConsumption(trajetConsump),
        'consumptionUnit': consUnit,
      };
    }
    return null;
  }

  Map<String, dynamic> calculateOverallAverageConsumption({required List<FuelEntryModel> entries}) {
    if (entries.length < 2) return {'overall': 0.0, 'periods': <double>[]};

    double totalDistance = 0.0;
    double totalLiters = 0.0;
    List<double> periods = [];

    final sorted = List<FuelEntryModel>.from(fuelEntries)..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));

    for (int i = 1; i < sorted.length; i++) {
      final dist = sorted[i].odometerKm - sorted[i - 1].odometerKm;
      if(dist > 0 && sorted[i-1].tankFull == 1){
        periods.add(dist / sorted[i-1].volumeLiters);
        totalDistance += dist;
        totalLiters += sorted[i].volumeLiters;
      }
    }

    double overall = totalLiters > 0 ? totalDistance / totalLiters : 0.0;

    return {'overall': overall, 'periods': periods};
  }

  String formatConsumption(double value) {
    final unit = unitController.consumptionUnit.value;
    if(unit == ConsumptionUnit.litersPer100km) return (value > 0 ? 100 / value : 0).toStringAsFixed(2);
    if(unit == ConsumptionUnit.milesPerGallon) return (value  * _kmPerLiterToMPGFactor).toStringAsFixed(2);
    return value.toStringAsFixed(2);
  }

  String getDistanceUnitString() => unitController.distanceUnit.value == DistanceUnit.miles
  ? 'Milhas (mi)'
  : 'Quilômetros (km)'.replaceAll(RegExp(r'\(.*\)'), '').trim();
  

  String getConsumptionUnitString() {
    final unit = unitController.consumptionUnit.value;
    String key = 'km/L';
    if(unit == ConsumptionUnit.litersPer100km) key = 'L/100km';
    if(unit == ConsumptionUnit.milesPerGallon) key = 'Milhas por Galão (MPG)';
    return tr(key).replaceAll(RegExp(r'\(.*\)'), '').trim();
  }

  double get overallTotalCost => fuelEntries.fold(0.0, (sum, entry) => sum + entry.totalCost);
  double get overallTotalDistance {
    if(fuelEntries.length < 2) return 0.0;
    final double latestKm = fuelEntries.first.odometerKm;
    final double oldestKm = fuelEntries.last.odometerKm;

    return latestKm > oldestKm ? latestKm - oldestKm : 0.0;
  }

  double get overallCostPerDistance {
    final double totalDistance = overallTotalDistance;
    if(totalDistance <= 0) return 0.0;
    return overallTotalCost / totalDistance;
  }

  String tr(String key, {Map<String, String>? parameters}) => languageController.translate(key, parameters: parameters);

  double get kmToMileFactor => _kmToMileFactor;
  
  void navigateToAddEntry(BuildContext context, {FuelEntryModel? data}) async {
    final currentOdometer = lastOdometer.value;
    final entry = await Get.to(() => FuelEntryScreen(lastOdometer: currentOdometer, entry: data));
    if (entry != null) {
      await saveFuel(entry);
    }
  }
}
