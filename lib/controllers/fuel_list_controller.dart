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
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';

class FuelListController extends GetxController {
  var fuelEntries = <FuelEntryModel>[].obs;
  var fuelTypeEntries = <TypeGasModel>[].obs;
  var vehicleEntries = <VehicleModel>[].obs;
  var gasStationEntries = <GasStationModel>[].obs;

  final FuelDb _db = FuelDb();
  final FuelRepository _repository = FuelRepository();

  final int vehicleId = 0;
  String fuelTypeName = '';
  String vehicleName = '';
  String stationName = '';

  static const double _alertThresholdKm = 100.0;
  static const double _kmToMileFactor = 0.621371;
  static const double _kmPerLiterToMPGFactor = 2.3521458;

  final UnitController unitController = Get.find<UnitController>();
  final VehicleController vehicleController = Get.find();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _sucessoMessage = ''.obs;

  var errorMessage = ''.obs;
  var isLoading = false.obs;
  var lastOdometer = Rxn<double>();
  var overallConsumption = 0.0.obs;
  var periodConsumptions = <double>[].obs;
  var updateAvailable = Rxn<AppUpdate>();
  var selectedVehicleFilter = Rxn<String>();
  var selectedFuelTypeFilter = Rxn<String>();
  var selectedStationFilter = Rxn<String>();
  var vehicleTypeMap = <String, String>{}.obs;
  var fuelTypeMap = <String, String>{}.obs;

  void navigateToAddEntry(BuildContext context, {FuelEntryModel? data}) async {
    final currentOdometer = lastOdometer.value;
    final entry = await Get.to(() => FuelEntryScreen(lastOdometer: currentOdometer, entry: data));
    if (entry != null) {
      await saveFuel(entry);
    }
  }

  @override
  void onInit() {
    loadFuel();
    loadTypeFuel();
    loadVehicle();
    loadStation();
    super.onInit();
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String error) {
    _errorMessage.value = error;
  }

  void _setSucesso(String sucesso) {
    _sucessoMessage.value = sucesso;
  }

  Future<void> loadFuel() async {
    try {
      _setLoading(true);
      _setError('');

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
      _setError('Não foi possível carregar os dados. Verifique sua conexão.');

      Get.snackbar(
        'Erro de Carregamento',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTypeFuel() async {
    final List<TypeGasModel> data = await _db.getGas();
    fuelTypeEntries.assignAll(data);
  }

  Future<void> loadVehicle() async {
    final List<VehicleModel> data = await _db.getVehicles();
    vehicleEntries.assignAll(data);
  }

  Future<void> loadStation() async {
    final List<GasStationModel> data = await _db.getStation();
    gasStationEntries.assignAll(data);
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    final db = await _db.getDb();
    if(data['pk_fuel'] == null){
      await db.insert('fuel_entries', data);  
      await loadFuel();    
    }else{
      await db.update(
        'fuel_entries', 
        data,
        where: 'pk_fuel = ?',
        whereArgs: [data['pk_fuel']]
      );
      await loadFuel();
    }
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteFuelEntrie(id);
    await loadFuel();
  }

  Future<String> backupEntries() async {
    if (fuelEntries.isEmpty) {
      await loadFuel();
    }
    if (fuelEntries.isEmpty) {
      return 'Nenhum registro para backup.';
    }

    final StringBuffer sb = StringBuffer(
      'Data,Hodometro,Litros,PrecoPorLitro,PrecoTotal,Posto,TipoCombustivel,TanqueCheio\n',
    );

    return sb.toString();
  }

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
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

  double get filteredOverallConsumption {
    final Map<String, dynamic> result = calculateOverallAverageConsumption(
      entries: filteredEntries,
    );
    return result['overall'] ?? 0.0;
  }

  double get overallTotalDistance {
    final entries = fuelEntries;
    if (entries.length < 2) return 0.0;

    final double latestKm = entries.first.odometerKm;
    final double oldestKm = entries.last.odometerKm;

    return latestKm > oldestKm ? latestKm - oldestKm : 0.0;
  }

  double get overallTotalCost {
    double totalCost = 0.0;
    for (final entry in fuelEntries) {
      totalCost += entry.totalCost;
    }
    return totalCost;
  }

  double get overallCostPerDistance {
    final totalDistanceKm = overallTotalDistance;
    if (totalDistanceKm <= 0) return 0.0;
    return overallTotalCost / totalDistanceKm;
  }

  String formatConsumption(double kmPerLiterValue) {
    final ConsumptionUnit unit = unitController.consumptionUnit.value;
    double formattedValue;

    switch (unit) {
      case ConsumptionUnit.kmPerLiter:
        formattedValue = kmPerLiterValue;
        break;
      case ConsumptionUnit.litersPer100km:
        formattedValue = kmPerLiterValue > 0 ? (100 / kmPerLiterValue) : 0;
        break;
      case ConsumptionUnit.milesPerGallon:
        formattedValue = kmPerLiterValue * _kmPerLiterToMPGFactor;
        break;
      default:
        formattedValue = kmPerLiterValue;
    }
    return formattedValue.toStringAsFixed(2);
  }

  String getConsumptionUnitString() {
    final ConsumptionUnit unit = unitController.consumptionUnit.value;
    String key;

    switch (unit) {
      case ConsumptionUnit.kmPerLiter:
        key = TranslationKeys.unitSettingsScreenKmPerLiter;
        break;
      case ConsumptionUnit.litersPer100km:
        key = TranslationKeys.unitSettingsScreenLitersPer100km;
        break;
      case ConsumptionUnit.milesPerGallon:
        key = TranslationKeys.unitSettingsScreenMpg;
        break;
    }

    return tr(key).replaceAll(RegExp(r'\(.*\)'), '').trim();
  }

  String getDistanceUnitString() {
    final bool isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
    final String key = isMiles
        ? TranslationKeys.unitSettingsScreenMiles
        : TranslationKeys.unitSettingsScreenKilometers;
    return tr(key).replaceAll(RegExp(r'\(.*\)'), '');
  }

  double get kmToMileFactor => _kmToMileFactor;

  Map<String, String>? get fuelAlertData {
    final entries = filteredEntries;

    if (entries.length < 2 || overallConsumption <= 0) {
      return null;
    }

    final lastEntry = entries.first;
    final previousEntry = entries[1];

    final double estimatedTankSize = 44.0;

    final distanceSinceLastFill =
        (lastEntry.odometerKm).toDouble() - (previousEntry.odometerKm).toDouble();
    final double overallConsumptionValue = overallConsumption.value;

    final double totalEstimatedRange = estimatedTankSize * overallConsumptionValue;
    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final bool isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
      final double rangeToDisplay = isMiles ? (estimatedRange * _kmToMileFactor) : estimatedRange;
      final String displayRange = rangeToDisplay.toStringAsFixed(0);

      final String distanceUnitStr = getDistanceUnitString();

      final double litersFilled = (lastEntry.volumeLiters).toDouble();
      final double trajetConsumptionKmPerLiter = (litersFilled > 0 && distanceSinceLastFill >= 0)
          ? distanceSinceLastFill / litersFilled
          : 0.0;

      final String displayTrajetConsumption = formatConsumption(trajetConsumptionKmPerLiter);
      final String consumptionUnitStr = getConsumptionUnitString();

      final versionLabel1 = tr(TranslationKeys.alertsThresholdMsg1);
      final versionLabel2 = tr(TranslationKeys.alertsThresholdMsg2);
      final alertText0 = '$displayRange $distanceUnitStr';
      final alertText1 = '$displayTrajetConsumption $consumptionUnitStr';

      return {
        'alertText': '$versionLabel1 $alertText0 $versionLabel2 $alertText1',
        'displayRange': displayRange,
        'distanceUnit': distanceUnitStr,
        'consumptionValue': displayTrajetConsumption,
        'consumptionUnit': consumptionUnitStr,
      };
    }
    return null;
  }

  Map<String, dynamic> calculateOverallAverageConsumption({required List<FuelEntryModel> entries}) {
    if (fuelEntries.length < 2) {
      return {'overall': 0.0, 'periods': <double>[]};
    }

    double totalDistance = 0.0;
    double totalLiters = 0.0;
    List<double> periodConsumptions = [];

    final List<FuelEntryModel> sortedEntries = List<FuelEntryModel>.from(fuelEntries);
    sortedEntries.sort((a, b) {
      return a.odometerKm.compareTo(b.odometerKm);
    });

    for (int i = 1; i < sortedEntries.length; i++) {
      final FuelEntryModel currentEntry = sortedEntries[i];
      final FuelEntryModel previousEntry = sortedEntries[i - 1];

      final double currentOdometer = currentEntry.odometerKm;
      final double previousOdometer = previousEntry.odometerKm;

      final double previousLiters = previousEntry.volumeLiters;
      final double currentLiters = currentEntry.volumeLiters;

      final double distance = currentOdometer - previousOdometer;

      double consumptionForThisPeriod = 0.0;

      if (distance > 0 && previousLiters > 0 && previousEntry.tankFull == 1) {
        consumptionForThisPeriod = distance / previousLiters;
      }

      periodConsumptions.add(consumptionForThisPeriod);

      totalDistance += distance;
      totalLiters += currentLiters;
    }

    double overall = (totalLiters <= 0) ? 0.0 : (totalDistance / totalLiters);

    return {'overall': overall, 'periods': calculateOverallAverageConsumption};
  }
}
