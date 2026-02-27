import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/fuel_entry_screen.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class FuelListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observáveis
  final _fuelEntries = <FuelEntryModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  List<FuelEntryModel> get fuelEntries => _fuelEntries;

  static const double _alertThresholdKm = 80.0;
  static const double _kmToMileFactor = 0.621371;
  static const double _kmPerLiterToMPGFactor = 2.3521458;

  final UnitController unitController = Get.find<UnitController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguageController languageController = Get.find<LanguageController>();

  var lastOdometer = Rxn<double>();
  var overallConsumption = 0.0.obs;

  var selectedVehicleID = Rxn<dynamic>();
  var selectedTipoID = Rxn<dynamic>();
  var selectedPostoID = Rxn<dynamic>();

  final RxMap<dynamic, Map<String, dynamic>> veiculosMap =
      <dynamic, Map<String, dynamic>>{}.obs;
  final RxMap<dynamic, Map<String, dynamic>> tiposMap =
      <dynamic, Map<String, dynamic>>{}.obs;
  final RxMap<dynamic, Map<String, dynamic>> postosMap =
      <dynamic, Map<String, dynamic>>{}.obs;
  final RxMap<dynamic, Map<String, dynamic>> servicesMap =
      <dynamic, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  Future<void> refreshAllData() async {
    isLoading.value = true;
    try {
      await loadAuxiliaryData();
      await loadFuel();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAuxiliaryData() async {
    var tipSnap = await _firestore.collection('tipo_combustivel').get();
    for (var doc in tipSnap.docs) {
      final data = doc.data();
      final id = data['pk_tipo'] ?? doc.id;
      tiposMap[id] = {
        'pk_tipo': id,
        'nome': data['nome'] ?? '',
        'abbr': data['abbr'] ?? '',
        'octane_rating': (data['octane_rating'] as num? ?? 0.0).toDouble(),
      };
    }
    var vecSnap = await _firestore.collection('veiculos').get();
    for (var doc in vecSnap.docs) {
      final data = doc.data();
      final id = data['pk_vehicle'] ?? doc.id;
      veiculosMap[id] = {
        'pk_vehicle': id,
        'nickname': data['nickname'] ?? '',
        'tank_capacity': (data['tank_capacity'] as num? ?? 0.0).toDouble(),
        'city': data['city'] ?? '',
        'plate': data['plate'] ?? '',
      };
    }

    var potSnap = await _firestore.collection('postos').get();
    for (var doc in potSnap.docs) {
      final data = doc.data();
      final id = data['pk_posto'] ?? doc.id;
      postosMap[id] = {
        'pk_posto': id,
        'nome': data['nome'] ?? '',
        'endereco': data['endereco'] ?? '',
        'brand': data['brand'] ?? '',
        'latitude': (data['latitude'] as num? ?? 0.0).toDouble(),
        'longitude': (data['longitude'] as num? ?? 0.0).toDouble(),
        'preco': (data['preco'] as num? ?? 0.0).toDouble(),
        'hasConvenientStore': data['hasConvenientStore'] ?? false,
        'is24Hours': data['is24Hours'] ?? false,
      };
    }
    var sevSnap = await _firestore.collection('service_type').get();
    for (var doc in sevSnap.docs) {
      final data = doc.data();
      final id = data['pk_posto'] ?? doc.id;
      servicesMap[id] = {
        'pk_service': id,
        'nome': data['nome'] ?? '',
        'abbr': data['abbr'] ?? '',
        'default_frequency_km': (data['default_frequency_km'] as num? ?? 0.0)
            .toDouble(),
      };
    }
  }

  Future<void> loadFuel() async {
    try {
      errorMessage.value = '';
      final snapshot = await _firestore
          .collection('fuels')
          .orderBy('data', descending: true)
          .get();

      final entries = snapshot.docs
          .map((doc) => FuelEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();

      fuelEntries.assignAll(entries);

      if (entries.isNotEmpty) {
        lastOdometer.value = entries
            .map((e) => e.odometerKm)
            .reduce((a, b) => a > b ? a : b);
      }

      final consumptionData = calculateOverallAverageConsumption();
      overallConsumption.value = consumptionData['overall'] as double;
    } catch (e) {
      errorMessage.value =
          'Não foi possível carregar os dados. Verifique sua conexão.';
    }
  }

  List<FuelEntryModel> get filteredFuelEntries {
    return fuelEntries.where((entry) {
      final vehicleInfo = veiculosMap[entry.vehicleId];
      final tipoInfo = tiposMap[entry.fuelTypeId];
      final postoInfo = postosMap[entry.gasStationId];

      final int vehicleID = vehicleInfo?['pk_vehicle'];
      final int tipoID = tipoInfo?['pk_tipo'];
      final int postoID = postoInfo?['pk_posto'];

      bool matchVehicle =
          selectedVehicleID.value == null ||
          vehicleID == selectedVehicleID.value;
      bool matchFuel =
          selectedTipoID.value == null || tipoID == selectedTipoID.value;
      bool matchPosto =
          selectedPostoID.value == null || postoID == selectedPostoID.value;
      return matchVehicle && matchFuel && matchPosto;
    }).toList();
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      DocumentReference docRef = _firestore.collection('fuels').doc();
      data['pk_fuel'] = docRef.id;
      data['data'] ??= FieldValue.serverTimestamp();

      await docRef.set(data);
      await loadFuel();
    } catch (e) {
      Get.snackbar('Erro', "Falha ao salvar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFuel(FuelEntryModel fuel) async {
    if (fuel.id == null) return;
    try {
      await _firestore.collection('fuels').doc(fuel.id).update(fuel.toMap());
      await loadFuel();
    } catch (e) {
      Get.snackbar('Erro', "Falha ao atualizar: $e");
    }
  }

  Future<void> deleteEntry(int id) async {
    // await _db.deleteFuelEntrie(id);
    await loadFuel();
  }

  Map<String, String>? get fuelAlertData {
    if (fuelEntries.length < 2 || overallConsumption <= 0) {
      return null;
    }

    final lastEntry = fuelEntries.first;
    final vehicleInfo = veiculosMap[lastEntry.vehicleId];

    final String vehicleName = vehicleInfo?['nickname'] ?? 'Veículo';

    final double tankSize =
        (vehicleInfo?['tank_capacity'] as double?) ?? lastEntry.tankCapacity;

    if (tankSize <= 0) return null;

    final previousEntry = fuelEntries[1];
    final distanceSinceLastFill =
        lastEntry.odometerKm - previousEntry.odometerKm;
    final double avgConsump = overallConsumption.value;

    final double totalEstimatedRange = tankSize * avgConsump;
    final double estimatedRange = totalEstimatedRange - distanceSinceLastFill;

    if (estimatedRange < _alertThresholdKm) {
      final bool isMiles =
          unitController.distanceUnit.value == DistanceUnit.miles;
      final double rangeToDisplay = isMiles
          ? (estimatedRange * _kmToMileFactor)
          : estimatedRange;

      final String distUnit = getDistanceUnitString();
      final String consUnit = getConsumptionUnitString();
      final String displayRange = rangeToDisplay.toStringAsFixed(0);

      final double trajetConsump = lastEntry.volumeLiters > 0
          ? distanceSinceLastFill / lastEntry.volumeLiters
          : 0.0;

      return {
        'alertText':
            'Autonomia restante: $displayRange $distUnit, Consumo no trajeto: ${formatConsumption(trajetConsump)} $consUnit',
        'displayRange': displayRange,
        'distanceUnit': distUnit,
        'consumptionValue': formatConsumption(trajetConsump),
        'consumptionUnit': consUnit,
        'vehicleName': vehicleName,
        'tankCapcity': tankSize.toString(),
      };
    }
    return null;
  }

  Map<String, dynamic> calculateOverallAverageConsumption() {
    final entriesToCalculate = filteredFuelEntries;

    if (entriesToCalculate.length < 2) {
      return {'overall': 0.0, 'periods': <double>[]};
    }

    final sorted = List<FuelEntryModel>.from(entriesToCalculate)
      ..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));

    double totalDistance = 0.0;
    double totalLiters = 0.0;
    List<double> periods = [];

    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final previous = sorted[i - 1];
      final dist = current.odometerKm - previous.odometerKm;

      if (dist > 0 && previous.tankFull == true) {
        double periodAvg = dist / current.volumeLiters;
        periods.add(periodAvg);

        totalDistance += dist;
        totalLiters += current.volumeLiters;
      }
    }

    double overall = totalLiters > 0 ? totalDistance / totalLiters : 0.0;

    return {'overall': overall, 'periods': periods};
  }

  String formatConsumption(double value) {
    final unit = unitController.consumptionUnit.value;
    if (unit == ConsumptionUnit.litersPer100km)
      return (value > 0 ? 100 / value : 0).toStringAsFixed(2);
    if (unit == ConsumptionUnit.milesPerGallon)
      return (value * _kmPerLiterToMPGFactor).toStringAsFixed(2);
    return value.toStringAsFixed(2);
  }

  String getDistanceUnitString() =>
      unitController.distanceUnit.value == DistanceUnit.miles
      ? 'Milhas (mi)'
      : 'Quilômetros (km)'.replaceAll(RegExp(r'\(.*\)'), '').trim();

  String getConsumptionUnitString() {
    final unit = unitController.consumptionUnit.value;
    String key = 'km/L';
    if (unit == ConsumptionUnit.litersPer100km) key = 'L/100km';
    if (unit == ConsumptionUnit.milesPerGallon) key = 'Milhas por Galão (MPG)';
    return tr(key).replaceAll(RegExp(r'\(.*\)'), '').trim();
  }

  void clearAllFilters() {
    selectedVehicleID.value = null;
    selectedTipoID.value = null;
    selectedPostoID.value = null;
  }

  double get overallTotalCost =>
      fuelEntries.fold(0.0, (sum, entry) => sum + entry.totalCost);
  double get overallTotalDistance {
    if (fuelEntries.length < 2) return 0.0;
    final double latestKm = fuelEntries.first.odometerKm;
    final double oldestKm = fuelEntries.last.odometerKm;

    return latestKm > oldestKm ? latestKm - oldestKm : 0.0;
  }

  double get overallCostPerDistance {
    final double totalDistance = overallTotalDistance;
    if (totalDistance <= 0) return 0.0;
    return overallTotalCost / totalDistance;
  }

  String tr(String key, {Map<String, String>? parameters}) =>
      languageController.translate(key, parameters: parameters);

  double get kmToMileFactor => _kmToMileFactor;

  void navigateToAddEntry(BuildContext context) async {
    final currentOdometer = lastOdometer.value;
    final result = await Get.to(
      () => FuelEntryScreen(lastOdometer: currentOdometer),
    );
    if (result != null) {
      if (result is Map<String, dynamic>) {
        await saveFuel(result);
      }
    }
  }

  void navigateToEditEntry(BuildContext context, FuelEntryModel entry) async {
    final currentOdometer = lastOdometer.value;
    final result = await Get.to(
      () => FuelEntryScreen(lastOdometer: currentOdometer, entry: entry),
      arguments: entry,
    );
    if (result == true || result != null) {
      await loadFuel();
      Get.snackbar(
        "Sucesso",
        "Abastecido com sucesso!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF00FF85).withOpacity(0.8),
        colorText: Colors.black,
        icon: const Icon(RemixIcons.check_line),
        margin: const EdgeInsets.all(15),
      );
    }
  }
}
