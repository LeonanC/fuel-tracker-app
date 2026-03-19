import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class HomeController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final lookupController = Get.find<LookupController>();
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

  var searchText = ''.obs;
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
    final userUID = _auth.currentUser?.uid;
    if (userUID == null) return;

    _firestore
        .collection('fuels')
        .where('fk_usuario', isEqualTo: userUID)
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
      isLoading.value = true;
      final userUID = _auth.currentUser?.uid;
      if (userUID == null) return;

      data['fk_usuario'] = userUID;
      data['data'] = FieldValue.serverTimestamp();

      await _firestore.collection('fuels').add(data);

      double odoAtual = (data['velocimetro'] as num).toDouble();
      double odoAnterior = lastOdometer.value ?? odoAtual;
      int xpGanho = _calcularXP(
        (data['litros_volume'] as num).toDouble(),
        odoAtual,
        odoAnterior,
      );

      await _firestore.collection('usuarios').doc(userUID).update({
        'xp': FieldValue.increment(xpGanho),
        'quilometragem': odoAtual,
      });

      Get.back();
      Get.snackbar(
        "Combustível Registrado!",
        "Você ganhou +$xpGanho de XP!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFF00FF85),
        colorText: Colors.black,
        icon: Icon(RemixIcons.medal_2_line),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Erro ao salvar', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  double getLatestOdometerForVehicle(dynamic vehicleId) {
    try {
      final lastEntry = fuelEntries.firstWhere((e) => e.vehicleId == vehicleId);
      return lastEntry.odometerKm;
    } catch (e) {
      final veiculoData = veiculosMap[vehicleId];
      return (veiculoData?['initial_odometer'] as num? ?? 0.0).toDouble();
    }
  }

  int _calcularXP(double litros, double odoAtual, double odoAnterior) {
    int xpPorLitro = litros.toInt();
    double kmPercorrido = odoAtual - odoAnterior;
    int xpPorKm = kmPercorrido > 0 ? (kmPercorrido ~/ 10) * 5 : 0;
    return xpPorLitro + xpPorKm;
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
    List<FuelEntryModel> list = fuelEntries;
    if (selectedVehicleID.value != null) {
      list = list.where((e) => e.vehicleId == selectedVehicleID.value).toList();
    }

    if (selectedTipoID.value != null) {
      list = list.where((e) => e.fuelTypeId == selectedTipoID.value).toList();
    }

    if (selectedPostoID.value != null) {
      list = list
          .where((e) => e.gasStationId == selectedPostoID.value)
          .toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      list = list.where((e) {
        final dadosPosto = postosMap[e.gasStationId];
        final nomePosto = dadosPosto?['nome']?.toString().toLowerCase() ?? "";

        final dadosVeiculo = veiculosMap[e.vehicleId];
        final nomeVeiculo =
            dadosVeiculo?['nickname']?.toString().toLowerCase() ?? "";

        final dadosTipo = tiposMap[e.fuelTypeId];
        final nomeTipo = dadosTipo?['nome']?.toString().toLowerCase() ?? "";

        return nomePosto.contains(query) ||
            nomeVeiculo.contains(query) ||
            nomeTipo.contains(query);
      }).toList();
    }
    return list;
  }

  double get gastoPorKmReal {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final novo = fuelEntries[0];
    final anterior = fuelEntries[1];

    double somaOdometro = novo.odometerKm + anterior.odometerKm;
    double volumeLitros = novo.volumeLiters;

    return (volumeLitros > 0) ? somaOdometro / volumeLitros : 0.0;
  }

  double get averageCostPerKm {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final novo = entries[0];
    final anterior = entries[1];

    double kmNoTrecho = novo.odometerKm - anterior.odometerKm;
    double custoTotal = novo.totalCost;

    return (kmNoTrecho > 0) ? custoTotal / kmNoTrecho : 0.0;
  }

  Map<String, String>? get fuelAlertData {
    if (filteredFuelEntries.isEmpty) return null;

    final last = filteredFuelEntries.first;
    final double level = last.tankCapacity;

    if (level > 15.0) return null;

    return {
      'vehicleName':
          'controller.veiculosMap[entry.vehicleId]?[nickname] ?? "---"',
      'displayRange': (level).toStringAsFixed(0),
      'level': '$level',
    };
  }

  void navigateToAddEntry(BuildContext context) async {
    double odometerToSend = selectedVehicleID.value != null
        ? getLatestOdometerForVehicle(selectedVehicleID.value)
        : (lastOdometer.value ?? 0.0);

    final result = await Get.to(
      () => HomeEntryPage(lastOdometer: odometerToSend),
    );
    if (result != null) {
      if (result is Map<String, dynamic>) {
        await saveFuel(result);
      }
    }
  }

  void navigateToEditEntry(BuildContext context, FuelEntryModel entry) async {
    double odometerToSend = getLatestOdometerForVehicle(entry.vehicleId);

    final result = await Get.to(
      () => HomeEntryPage(lastOdometer: odometerToSend, entry: entry),
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
