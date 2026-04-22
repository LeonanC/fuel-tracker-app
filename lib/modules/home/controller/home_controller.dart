import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:share_plus/share_plus.dart';

class HomeController extends GetxController {
  final auth = FirebaseAuth.instance;
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

  final usuariosMap = <String, dynamic>{}.obs;
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
      await carregarDonoDoRegistro(auth.currentUser!.uid);
      setupFuelStream();
    } catch (e) {
      debugPrint("Erro na inicialização: $e");
    } finally {
      if (fuelEntries.isEmpty) isLoading.value = false;
    }
  }

  Future<void> _loadAuxiliaryData() async {
    final results = await Future.wait([
      _firestore.collection('usuarios').get(),
      _firestore.collection('tipo_combustivel').get(),
      _firestore.collection('veiculos').get(),
      _firestore.collection('postos').get(),
    ]);

    final usuarioSnap = results[0];
    final tipSnap = results[1];
    final vecSnap = results[2];
    final postSnap = results[3];

    for (var doc in usuarioSnap.docs) {
      final data = doc.data();
      usuariosMap[doc.id] = {
        'id': doc.id,
        'email': data['email'] ?? '',
        'nome': data['nome'] ?? '',
        'fotoUrl': data['foto_url'] ?? '',
      };
    }

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

  Future<void> updateVehicleOdometer(
    String vehicleId,
    double newOdometer,
  ) async {
    try {
      await _firestore.collection('veiculos').doc(vehicleId).update({
        'initial_odometer': newOdometer,
      });
      if (veiculosMap.containsKey(vehicleId)) {
        veiculosMap[vehicleId]?['initial_odometer'] = newOdometer;
      }
    } catch (e) {
      print("Erro ao atualizar odômetro do veículo: $e");
    }
  }

  Future<void> setupFuelStream() async {
    final userUID = auth.currentUser?.uid;
    if (userUID == null) return;

    _firestore
        .collection('fuels')
        .where(
          Filter.or(
            Filter('fk_usuario', isEqualTo: userUID),
            Filter('sharedWith', arrayContains: userUID),
          ),
        )
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
            _showSnackbar("Erro", "Falha ao sincronizar", isError: true);
          },
        );
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final userUID = auth.currentUser?.uid;
      if (userUID == null) return;

      data['fk_usuario'] = userUID;
      data['data'] = FieldValue.serverTimestamp();

      await _firestore.collection('fuels').add(data);

      Get.back();
      _showSnackbar("Sucesso", "Abastecimento registrado!");
    } catch (e) {
      _showSnackbar('Erro', 'Falha ao salvar', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(String? itemId) async {
    if (itemId == null || itemId.isEmpty) return;

    try {
      isLoading.value = true;
      await _firestore.collection('fuels').doc(itemId).delete();
      fuelEntries.removeWhere((item) => item.id == itemId);
      fuelEntries.refresh();
      _showSnackbar("Sucesso", "Item removido com sucesso!");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível deletar", isError: true);
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
    try {
      isLoading.value = true;
      final data = fuel.toMap();
      data.remove('pk_fuel');

      await _firestore.collection('fuels').doc(fuel.id).update(data);

      Get.back();
      _showSnackbar("Sucesso", "Abastecimento atualizado com sucesso!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao atualizar: $e", isError: true);
    } finally {
      isLoading.value = false;
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

  List<FuelEntryModel> get meusAbastecimentos {
    final uid = auth.currentUser?.uid;
    return filteredFuelEntries.where((e) => e.user == uid).toList();
  }

  List<FuelEntryModel> get fuelEntriesCompartilhados {
    final uid = auth.currentUser?.uid;
    return filteredFuelEntries.where((e) => e.user != uid).toList();
  }

  double get gastoPorKmReal {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;

    final novo = fuelEntries[0];
    final anterior = fuelEntries[1];

    double somaOdometro = novo.odometerKm - anterior.odometerKm;
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

    if (kmNoTrecho <= 0) return 0.0;

    return (custoTotal / kmNoTrecho) * 100;
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

  Future<void> compartilharComUsuario(
    String registroId,
    String uidAmigo,
  ) async {
    try {
      isLoading.value = true;

      await _firestore.collection('fuels').doc(registroId).update({
        'sharedWith': FieldValue.arrayUnion([uidAmigo]),
      });
      _showSnackbar("Sucesso", "Registro compartilhado com sucesso!");
    } catch (e) {
      _showSnackbar("Erro", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> carregarDonoDoRegistro(String userId) async {
    if (usuariosMap.containsKey(userId)) return;

    final doc = await _firestore.collection('usuarios').doc(userId).get();
    if (doc.exists) {
      usuariosMap[userId] = doc.data();
    }
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

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.8)
          : Colors.greenAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: Icon(
        isError ? RemixIcons.error_warning_line : RemixIcons.check_line,
        color: Colors.white,
      ),
    );
  }
}
