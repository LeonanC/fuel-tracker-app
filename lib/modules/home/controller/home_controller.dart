import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/station_model.dart';
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
  var postos = <StationModel>[].obs;
  var tipos = <TypeGasModel>[].obs;

  var veiculosMap = <String, Map<String, dynamic>>{}.obs;
  var postosMap = <String, Map<String, dynamic>>{}.obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  var selectedVehicleID = RxnString();
  var selectedTipoID = RxnString();
  var selectedPostoID = RxnString();
  var isLoading = false.obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final userUID = _supabase.auth.currentUser?.id;
      if (userUID == null) return;

      final results = await Future.wait([
        _supabase.from('veiculos').select(),
        _supabase
            .from('abastecimentos')
            .select()
            .or('fk_usuario.eq.$userUID')
            .order('velocimetro', ascending: false),
        _supabase.from('postos').select(),
        _supabase.from('tipo_combustivel').select(),
      ]);

      final vehicleData = results[0] as List;
      vehicles.value = vehicleData.map((e) => VehicleModel.fromMap(e)).toList();
      veiculosMap.value = {for (var v in vehicleData) v['id'].toString(): v};

      final homeData = results[1] as List;
      fuelEntries.value = homeData
          .map((f) => FuelEntryModel.fromMap(f))
          .toList();

      final postoData = results[2] as List;
      postos.value = postoData.map((p) => StationModel.fromMap(p)).toList();
      postosMap.value = {for (var p in postoData) p['pk_posto'].toString(): p};

      final tiposData = results[3] as List;
      tipos.value = tiposData.map((t) => TypeGasModel.fromMap(t)).toList();
      tiposMap.value = {for (var t in tiposData) t['pk_tipo'].toString(): t};
    } finally {
      isLoading.value = false;
    }
  }

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

  double get totalGastoNoMes {
    final agora = DateTime.now();

    return filteredFuelEntries
        .where((entry) {
          if (entry.entryDate == null) return false;
          return entry.entryDate!.month == agora.month &&
              entry.entryDate!.year == agora.year;
        })
        .fold(0.0, (sum, item) => sum + item.totalCost);
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
        final posto = dadosPosto?['nome']?.toString().toLowerCase() ?? '';
        final dadosVeiculo = veiculosMap[e.vehicleId];
        final veiculo =
            dadosVeiculo?['nickname']?.toString().toLowerCase() ?? '';
        final dadosTipo = tiposMap[e.fuelTypeId];
        final tipo = dadosTipo?['nome']?.toString().toLowerCase() ?? '';

        return posto.contains(query) ||
            veiculo.contains(query) ||
            tipo.contains(query);
      }).toList();
    }
    return list;
  }

  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      await _supabase.from('abastecimentos').insert(data);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar no banco", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFuel(FuelEntryModel data) async {
    try {
      if (data.id == null) return;
      isLoading.value = true;

      await _supabase
          .from('abastecimentos')
          .update(data.toMap())
          .eq('pk_fuel', data.id!);
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
        vehicles[index] = vehicles[index].copyWith(
          initialOdometer: newOdometer,
        );
        if (veiculosMap.containsKey(vehicleId)) {
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
    if (result == true) {
      _showSnackbar("Sucesso", "Abastecimento registrado!");
      fetchData();
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
      fetchData();
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
