import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/registro/pages/home_entry_page.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final _supabase = Supabase.instance.client;
  final settings = Get.find<SettingController>();

  var vehicles = <VehicleModel>[].obs;
  var fuelEntries = <FuelEntryModel>[].obs;
  var postos = <GasStationModel>[].obs;
  var tipos = <TypeGasModel>[].obs;

  var veiculosMap = <String, Map<String, dynamic>>{}.obs;
  var postosMap = <String, Map<String, dynamic>>{}.obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  var selectedVehicleID = RxnString();
  var selectedTipoID = RxnString();
  var selectedPostoID = RxnString();
  var isLoading = false.obs;
  var searchText = ''.obs;

  double get totalGastoFiltrado {
    return filteredFuelEntries.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  double get kmRodadoTotal {
    final list = filteredFuelEntries;
    if (list.length < 2) return 0.0;
    return list.first.odometerKm - list.last.odometerKm;
  }

  double get consumoMediaGeral {
    final entries = filteredFuelEntries;
    if (entries.length < 2) return 0.0;
    final atual = entries[0];
    final anterior = entries[1];

    final double distancia = atual.odometerKm - anterior.odometerKm;
    final double litros = atual.volumeLiters;
    if (litros <= 0) return 0.0;

    return distancia / litros;
  }

  double get odometerAnterior {
    final entries = filteredFuelEntries;
    if (entries.length >= 2) {
      return entries[1].odometerKm;
    }

    final veiculo = vehicles.firstWhereOrNull(
      (v) => v.id == selectedVehicleID.value,
    );
    return veiculo?.initialOdometer ?? 0.0;
  }

  Map<String, double> get gastosPorMes {
    Map<String, double> totais = {};
    for (var entry in filteredFuelEntries) {
      if (entry.entryDate == null) continue;
      String chaveMes =
          "${entry.entryDate!.month.toString().padLeft(2, '0')}/${entry.entryDate!.year}";
      totais[chaveMes] = (totais[chaveMes] ?? 0.0) + entry.totalCost;
    }
    return totais;
  }

  List<double> get ultimosSeisMeses {
    final agora = DateTime.now();
    List<double> valores = List.filled(6, 0.0);

    for (var entry in filteredFuelEntries) {
      if (entry.entryDate == null) continue;
      int diffMeses =
          (agora.year - entry.entryDate!.year) * 12 +
          (agora.month - entry.entryDate!.month);

      if (diffMeses >= 0 && diffMeses < 6) {
        valores[5 - diffMeses] += entry.totalCost;
      }
    }
    return valores;
  }

  List<FuelEntryModel> get filteredFuelEntries {
    List<FuelEntryModel> list = fuelEntries.toList();

    if (selectedVehicleID.value != null && selectedVehicleID.value!.isNotEmpty) {
      list = list.where((e) => e.vehicleId == selectedVehicleID.value).toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      list = list.where((e) {
        final posto =
            postosMap[e.gasStationId]?['nome']?.toString().toLowerCase() ?? '';
        return posto.contains(query);
      }).toList();
    }
    return list;
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('abastecimentos')
          .insert(data)
          .select()
          .single();

      final newEntry = FuelEntryModel.fromMap(response);
      fuelEntries.insert(0, newEntry);

      _showSnackbar("Sucesso", "Abastecimento registrado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar no banco", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFuel(FuelEntryModel data) async {
    try {
      isLoading.value = true;

      await _supabase
          .from('abastecimentos')
          .update(data.toMap())
          .eq('pk_fuel', data.id!);

      final index = fuelEntries.indexWhere((e) => e.id == data.id);
      if (index != -1) {
        fuelEntries[index] = data;
        fuelEntries.refresh();
      }

      _showSnackbar("Sucesso", "Registro atualizado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha na atualização", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVehicleOdometer(
    String vehicleId,
    double newOdometer,
  ) async {
    try {
      await _supabase
          .from('veiculos')
          .update({'initial_odometer': newOdometer})
          .eq('id', vehicleId);

      int index = vehicles.indexWhere((e) => e.id == vehicleId);
      if (index != -1) {
        vehicles[index] = vehicles[index].copyWith(initialOdometer: newOdometer);
        if(veiculosMap.containsKey(vehicleId)){
          veiculosMap[vehicleId]!['initial_odometer'] = newOdometer;
        }
        vehicles.refresh();
        veiculosMap.refresh();
      }
    } catch (e) {
      _showSnackbar("Erro", "Erro ao sincronizar odômetro: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFuel(String id) async {
    try {
      await _supabase.from('abastecimentos').delete().eq('pk_fuel', id);
      fuelEntries.removeWhere((element) => element.id == id);
      _showSnackbar("Sucesso", "Registro removido!");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível deletar", isError: true);
    }
  }

  Future<void> refreshData() async {}

  void onVehicleChanged(String? vehicleId) {
    selectedVehicleID.value = vehicleId;
  }

  Map<String, String>? get fuelAlertData {
    if (fuelEntries.isEmpty || selectedVehicleID.value == null) return null;

    final vehicleEntries = fuelEntries
        .where((e) => e.vehicleId == selectedVehicleID.value)
        .toList();
    if (vehicleEntries.isEmpty) return null;

    final last = vehicleEntries.first;

    final double currentLevel = last.tankCapacity;
    if (currentLevel > 10.0) return null;

    final vehicleInfo = veiculosMap[selectedVehicleID.value.toString()];
    final String nickname =
        vehicleInfo?['nickname'] ?? vehicleInfo?['modelo'] ?? "Veiculo";
    final double totalCap = (vehicleInfo?['tank_capacity'] as num? ?? 0.0)
        .toDouble();

    String consumoNoTrajeto = "---";
    if (vehicleEntries.length >= 2) {
      double media = last.calculateConsumption(vehicleEntries[1]);
      consumoNoTrajeto = "${media.toStringAsFixed(2)} km/L";
    }

    return {
      'vehicleName': nickname,
      'tank': totalCap.toString(),
      'displayRange': currentLevel > 0
          ? currentLevel.toStringAsFixed(1)
          : "---",
      'level': currentLevel.toString(),
      'consumptionValue': consumoNoTrajeto,
      'message': currentLevel <= 5.0 ? "Reserva Critica!" : "Nível Baixo",
      'distanceUnit': 'L',
    };
  }

  void navigateToAddEntry(BuildContext context) async {
    final result = await Get.toNamed('/fuel_entry');
    if (result != null) {
      if (result is Map<String, dynamic>) {
        // await saveFuel(result);
      } else {
        // fetchInitialData();
      }
    }
  }

  void navigateToEditEntry(BuildContext context, FuelEntryModel entry) async {
    double odometerToSend = odometerAnterior;

    final result = await Get.to(
      () => HomeEntryPage(lastOdometer: odometerToSend, entry: entry),
      arguments: entry,
    );
    if (result == true) {
      _showSnackbar("Sucesso", "Registro atualizado!");
      // fetchInitialData();
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
