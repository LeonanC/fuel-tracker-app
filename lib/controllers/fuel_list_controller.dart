import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/controllers/vehicle_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class FuelListController extends GetxController {
  final FuelDb _db = FuelDb();

  var loadedEntries = <FuelEntry>[].obs;

  static const double _alertThresholdKm = 100.0;
  static const double _kmToMileFactor = 0.621371;
  static const double _kmPerLiterToMPGFactor = 2.3521458;
  static const double _lastOdometer = 0.0;

  final GasStationController gasStationController = Get.find<GasStationController>();
  final VehicleController vehicleController = Get.find<VehicleController>();
  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguageController languageController = Get.find<LanguageController>();

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

  List<String> get availableGasStationNames {
    final List<String> names = gasStationController.stations
        .map((station) => station.nome)
        .toList();

    final List<String> uniqueEntryStations = loadedEntries
        .where((entry) => entry.posto != null && entry.posto!.isNotEmpty)
        .map((entry) => entry.posto!)
        .toSet()
        .toList();

    Set<String> allStations = {...names, ...uniqueEntryStations};

    allStations.removeWhere((name) => name.isEmpty);

    return allStations.toList();
  }

  @override
  void onInit() {
    _initializeData();
    loadFuelEntries();
    ever(languageController.currentLanguage, (_) => _initializeData());
    super.onInit();
  }

  Future<double?> getLastOdometerReading(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _lastOdometer;
  }

  

  String? validateFuelType(String? value) {
    // if(value == null || value.isEmpty){
    //   return tr(TranslationKeys.validationRequiredFuelType);
    // }
    return null;
  }

  String? validateLiters(String? value) {
    // if(_getLitersValue() == null || _getLitersValue()! <= 0){
    //   return tr(TranslationKeys.validationRequiredValidLiters);
    // }
    return null;
  }

  String? validatePricePerLiter(String? value) {
    // if(_getPricePerLiterValue() == null || _getPricePerLiterValue()! <= 0){
    //   return tr(TranslationKeys.validationRequiredValidPricePerLiter);
    // }
    return null;
  }

  String? validateTotalPrice(String? value) {
    // if(_getTotalPriceValue() == null || _getTotalPriceValue()! <= 0){
    //   return tr(TranslationKeys.validationRequiredValidTotalPrice);
    // }
    return null;
  }

  String? validateOdometer(String? value) {
    // final double? odometer = _getOdometerValue();
    // if(odometer == null || odometer <= 0){
    //   return tr(TranslationKeys.validationRequiredOdometer);
    // }
    // if(lastOdometer != null && odometer < lastOdometer!){
    //   return tr(TranslationKeys.entryScreenValidadeOdometerMustBeGreater, parameters: {'name': lastOdometer!.toStringAsFixed(0)});
    // }
    // return null;
  }

  MoneyMaskedTextController litrosController = MoneyMaskedTextController();
  MoneyMaskedTextController kmController = MoneyMaskedTextController();
  MoneyMaskedTextController pricePerLiterController = MoneyMaskedTextController();
  MoneyMaskedTextController totalPriceController = MoneyMaskedTextController();

  double? getOdometerValue() => kmController.numberValue;
  double? getLitersValue() => litrosController.numberValue;
  double? getPricePerLiterValue() => pricePerLiterController.numberValue;
  double? getTotalPriceValue() => totalPriceController.numberValue;

  void calculatePrice() {
    final double? liters = getLitersValue();
    final double? pricePerLiter = getPricePerLiterValue();
    final double? totalPriceEntered = getTotalPriceValue();

    if (liters != null && pricePerLiter != null) {
      final double calculatedTotal = liters * pricePerLiter;
      totalPriceController.removeListener(calculatePrice);
      totalPriceController.updateValue(calculatedTotal);
      totalPriceController.addListener(calculatePrice);
    } else if (liters != null && totalPriceEntered != null && liters > 0) {
      final calculatedPricePerLiter = totalPriceEntered / liters;
      pricePerLiterController.removeListener(calculatePrice);
      pricePerLiterController.updateValue(calculatedPricePerLiter);
      pricePerLiterController.addListener(calculatePrice);
    } else if (pricePerLiter != null && totalPriceEntered != null && pricePerLiter > 0) {
      final calculatedLiters = totalPriceEntered / pricePerLiter;
      litrosController.removeListener(calculatePrice);
      litrosController.updateValue(calculatedLiters);
      litrosController.addListener(calculatePrice);
    }
  }

  Future<void> loadFuelEntries() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Map<String, dynamic>> maps = await _db.getAllFuelEntries();
      final List<FuelEntry> entries = maps.map((map) => FuelEntry.fromMap(map)).toList();
      entries.sort((a, b) => b.dataAbastecimento.compareTo(a.dataAbastecimento));
      loadedEntries.assignAll(entries);

      final Map<String, dynamic> consumptionData = calculateOverallAverageConsumption(
        entries: entries,
      );
      overallConsumption.value = consumptionData['overall'] as double;
      lastOdometer.value = await _db.getLastOdometer();
    } catch (e) {
      errorMessage.value = 'Falha ao carregar registros: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeData() async {
    loadFuelEntries();
    vehicleController.loadVehicles();
    vehicleTypeMap.value = {
      'Suburbanona': 'Suburbanona',
      'Fit Prata': 'Fit Prata',
      'Cityzão': 'Cityzão',
    };
    fuelTypeMap.value = {
      'Gasolina Comum': tr(TranslationKeys.fuelTypeGasolineComum),
      'Gasolina Aditivada': tr(TranslationKeys.fuelTypeGasolineAditivada),
      'Etanol (Álcool)': tr(TranslationKeys.fuelTypeEthanolAlcool),
      'Gasolina Premium': tr(TranslationKeys.fuelTypeGasolinePremium),
      'Outro': tr(TranslationKeys.fuelTypeOther),
    };
  }

  Future<void> saveFuel(FuelEntry newFuel) async {
    final fuelToSave = newFuel.id!.isEmpty ? newFuel.copyWith(id: const Uuid().v4()) : newFuel;

    await _db.insertFuel(fuelToSave);
    await loadFuelEntries();
    final isNew = loadedEntries.indexWhere((f) => f.id == fuelToSave.id) == -1;

    if (isNew) {
      Get.snackbar(
        'Sucesso',
        'Posto adicionado: ${fuelToSave.posto}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Sucesso',
        'Posto atualizado: ${fuelToSave.posto}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    await _db.deleteFuelEntrie(id);
    await loadFuelEntries();
  }

  Future<String> backupEntries() async {
    if (loadedEntries.isEmpty) {
      await loadFuelEntries();
    }
    if (loadedEntries.isEmpty) {
      return 'Nenhum registro para backup.';
    }

    final StringBuffer sb = StringBuffer(
      'Data,Hodometro,Litros,PrecoPorLitro,PrecoTotal,Posto,TipoCombustivel,TanqueCheio\n',
    );

    return sb.toString();
  }

  Future<List<FuelEntry>> getAllEntriesForExport() async {
    if (loadedEntries.isEmpty && !isLoading.value) {
      await loadFuelEntries();
    }

    final List<FuelEntry> sortedMaps = List.from(loadedEntries);
    sortedMaps.sort((a, b) => b.dataAbastecimento.compareTo(a.dataAbastecimento));

    await Future.delayed(const Duration(milliseconds: 10));

    return sortedMaps;
  }

  Future<void> clearAllData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final int deletedCount = await _db.deleteAll();
      await loadFuelEntries();
      print('Total de $deletedCount registros apagados.');
    } catch (e) {
      errorMessage.value = 'Falha ao limpar todos os dados: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String tr(String key, {Map<String, String>? parameters}) {
    return languageController.translate(key, parameters: parameters);
  }

  List<FuelEntry> get filteredEntries {
    return loadedEntries.where((entry) {
      bool matchesVehicle = 
        selectedVehicleFilter.value == null || entry.veiculo == selectedVehicleFilter.value;
      bool matchesFuelType =
          selectedFuelTypeFilter.value == null || entry.tipo == selectedFuelTypeFilter.value;
      bool matchesStation =
          selectedStationFilter.value == null || entry.posto == selectedStationFilter.value;
      return matchesFuelType && matchesStation;
    }).toList();
  }

  void setVeiculoFilter(String? vehicle){
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
    final entries = loadedEntries;
    if (entries.length < 2) return 0.0;
    final double latestKm = entries.first.quilometragem.toDouble();
    final double oldestKm = entries.last.quilometragem.toDouble();

    return latestKm > oldestKm ? latestKm - oldestKm : 0.0;
  }

  double get overallTotalCost {
    double totalCost = 0.0;
    for (final entry in loadedEntries) {
      totalCost += entry.totalPrice ?? 0.0;
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
        (lastEntry.quilometragem).toDouble() - (previousEntry.quilometragem).toDouble();
    final double overallConsumptionValue = overallConsumption.value;

    final double totalEstimatedRange = estimatedTankSize * overallConsumptionValue;
    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final bool isMiles = unitController.distanceUnit.value == DistanceUnit.miles;
      final double rangeToDisplay = isMiles ? (estimatedRange * _kmToMileFactor) : estimatedRange;
      final String displayRange = rangeToDisplay.toStringAsFixed(0);

      final String distanceUnitStr = getDistanceUnitString();

      final double litersFilled = (lastEntry.litros).toDouble();
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

  Map<String, dynamic> calculateOverallAverageConsumption({required List<FuelEntry> entries}) {
    if (loadedEntries.length < 2) {
      return {'overall': 0.0, 'periods': <double>[]};
    }

    double totalDistance = 0.0;
    double totalLiters = 0.0;
    List<double> periodConsumptions = [];

    final List<FuelEntry> sortedEntries = List<FuelEntry>.from(loadedEntries);
    sortedEntries.sort((a, b) {
      return a.quilometragem.compareTo(b.quilometragem);
    });

    for (int i = 1; i < sortedEntries.length; i++) {
      final FuelEntry currentEntry = sortedEntries[i];
      final FuelEntry previousEntry = sortedEntries[i - 1];

      final double currentOdometer = currentEntry.quilometragem;
      final double previousOdometer = previousEntry.quilometragem;

      final double previousLiters = previousEntry.litros;
      final double currentLiters = currentEntry.litros;

      final double distance = currentOdometer - previousOdometer;

      double consumptionForThisPeriod = 0.0;

      if (distance > 0 && previousLiters > 0 && previousEntry.tanqueCheio == 1) {
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

extension FuelEntryCopWith on FuelEntry {
  FuelEntry copyWith({
    String? id,
    String? tipo,
    DateTime? dataAbastecimento,
    String? veiculo,
    String? posto,
    double? quilometragem,
    double? litros,
    double? pricePerLiter,
    double? totalPrice,
    bool? tanqueCheio,
    String? comprovantePath,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      dataAbastecimento: dataAbastecimento ?? this.dataAbastecimento,
      veiculo: veiculo ?? this.veiculo,
      posto: posto ?? this.posto,
      quilometragem: quilometragem ?? this.quilometragem,
      litros: litros ?? this.litros,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      tanqueCheio: tanqueCheio ?? this.tanqueCheio,
      comprovantePath: comprovantePath ?? this.comprovantePath,
    );
  }

  
}
