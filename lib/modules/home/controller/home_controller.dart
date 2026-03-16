import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final settingsController = Get.find<SettingController>();
  final currencyController = Get.find<CurrencyController>();

  double alertThresholdKm = 80.0;
  double kmToMileFactor = 80.0;
  double kmPerLiterToMPGFactor = 80.0;

  // Observáveis
  final fuelEntries = <FuelEntryModel>[].obs;
  final isLoading = false.obs;

  final postosMap = <dynamic, Map<String, dynamic>>{}.obs;
  final veiculosMap = <dynamic, Map<String, dynamic>>{}.obs;
  final tiposMap = <dynamic, Map<String, dynamic>>{}.obs;
  final servicesMap = <dynamic, Map<String, dynamic>>{}.obs;

  var selectedPostoID = Rxn<dynamic>();
  var selectedVehicleID = Rxn<dynamic>();
  var selectedTipoID = Rxn<dynamic>();
  var lastOdometer = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _loadAuxiliaryData();
      setupFuelStream();
    } catch (e) {
      print("Erro na inicialização: $e");
    } finally {
      if (fuelEntries.isEmpty) isLoading.value = false;
    }
  }

  Future<void> _loadAuxiliaryData() async {
    final results = await Future.wait([
      _firestore.collection('tipo_combustivel').get(),
      _firestore.collection('veiculos').get(),
      _firestore.collection('postos').get(),
    ]);

    final tipSnap = results[0];
    final vecSnap = results[1];
    final postSnap = results[2];

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
    for (var doc in vecSnap.docs) {
      final data = doc.data();
      final id = data['pk_vehicle'] ?? doc.id;
      veiculosMap[id] = {
        'pk_vehicle': id,
        'nickname': data['nickname'] ?? '',
        'plate': data['plate'] ?? '',
        'is_mercosul': data['is_mercosul'] ? true : false,
        'city': data['city'] ?? '',
        'make': data['make'] ?? '',
        'model': data['model'] ?? '',
        'year': data['year'] ?? 0,
        'fk_type_fuel': data['fk_type_fuel'] ?? 0,
        'initial_odometer': (data['initial_odometer'] as num? ?? 0.0)
            .toDouble(),
        'tank_capacity': (data['tank_capacity'] as num? ?? 0.0).toDouble(),
      };
    }
    for (var doc in postSnap.docs) {
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
  }

  Future<void> setupFuelStream() async {
    _firestore
        .collection('fuels')
        .orderBy('velocimetro', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final entries = snapshot.docs
                .map((doc) => FuelEntryModel.fromFirestore(doc.data(), doc.id))
                .toList();

            fuelEntries.assignAll(entries);

            if (entries.isNotEmpty) {
              lastOdometer.value = entries.first.odometerKm;
            }

            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar(
              "Erro",
              "Falha ao sincronizar: $e",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
            );
          },
        );
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('fuels').add(data);
      Get.back();
    } catch (e) {
      Get.snackbar('Erro ao salvar', e.toString());
    }
  }

  Future<void> updateFuel(FuelEntryModel fuel) async {
    if (fuel.id == null) return;
    try {
      await _firestore.collection('fuels').doc(fuel.id).update(fuel.toMap());
    } catch (e) {
      Get.snackbar('Erro', "Falha ao atualizar: $e");
    }
  }

  List<FuelEntryModel> get filteredFuelEntries {
    if (selectedVehicleID.value == null) return fuelEntries;
    return fuelEntries
        .where((e) => e.vehicleId == selectedVehicleID.value)
        .toList();
  }

  double get averageConsumption {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final double dist = (entries.first.odometerKm - entries.last.odometerKm)
        .toDouble();

    double liters = 0.0;
    for (int i = 0; i < entries.length - 1; i++) {
      liters += entries[i].volumeLiters;
    }

    return (dist > 0 && liters > 0) ? dist / liters : 0.0;
  }

  double get averageCostPerKm {
    final entries = filteredFuelEntries;
    if (entries.isEmpty) return 0.0;

    double totalCost = entries.fold(0.0, (sum, item) => sum + item.totalCost);
    double totalKm = (entries.first.odometerKm - entries.last.odometerKm)
        .toDouble();

    return totalKm > 0 ? totalCost / totalKm : 0.0;
  }

  Map<String, String>? get fuelAlertData {
    if (filteredFuelEntries.isEmpty) return null;

    final last = filteredFuelEntries.first;
    final double level = last.tankCapacity;

    if (level > 15.0) return null;

    return {
      'vehicleName':
          'controller.veiculosMap[entry.vehicleId]?[nickname] ?? "---"',
      'displayRange': (level * averageConsumption).toStringAsFixed(0),
      'level': '$level',
    };
  }

  void navigateToAddEntry(BuildContext context) async {
    final currentOdometer = lastOdometer.value;
    final result = await Get.to(
      () => HomeEntryPage(lastOdometer: currentOdometer),
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
      () => HomeEntryPage(lastOdometer: currentOdometer, entry: entry),
      arguments: entry,
    );
    if (result == true || result != null) {
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
