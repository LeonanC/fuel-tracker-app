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
  final SupabaseClient _supabase = Supabase.instance.client;
  final settings = Get.find<SettingController>();

  var isLoading = false.obs;
  var searchText = ''.obs;
  var vehicles = <VehicleModel>[].obs;
  var veiculosMap = <String, Map<String, dynamic>>{}.obs;
  var postos = <GasStationModel>[].obs;
  var postosMap = <String, Map<String, dynamic>>{}.obs;
  var tipos = <TypeGasModel>[].obs;
  var tiposMap = <String, Map<String, dynamic>>{}.obs;

  var fuelEntries = <FuelEntryModel>[].obs;
  var sharedWithMeEntries = <FuelEntryModel>[].obs;
  var usuariosMap = <String, dynamic>{}.obs;
  var todosUsarios = <Map<String, dynamic>>[].obs;

  var selectedVehicleID = Rxn<dynamic>();
  var selectedTipoID = Rxn<dynamic>();
  var selectedPostoID = Rxn<dynamic>();

  var veiculosList = <Map<String, dynamic>>[].obs;
  var tiposList = <Map<String, dynamic>>[].obs;
  var postosList = <Map<String, dynamic>>[].obs;

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final results = await Future.wait([
        _supabase.from('veiculos').select(),
        _supabase.from('usuarios').select('id, nome, foto_url'),
        _supabase.from('postos').select(),
        _supabase.from('tipo_combustivel').select(),
        _supabase
            .from('abastecimentos')
            .select()
            .or('fk_usuario.eq.$userId, shared_with.cs.{$userId}')
            .order('data', ascending: false),
      ]);

      final vehicleData = results[0] as List;
      vehicles.value = vehicleData.map((e) => VehicleModel.fromMap(e)).toList();
      veiculosMap.value = {for (var v in vehicleData) v['id'].toString(): v};

      final usersData = results[1] as List;
      todosUsarios.value = List<Map<String, dynamic>>.from(usersData);
      usuariosMap.value = {for (var u in usersData) u['id'].toString(): u};

      final postosData = results[2] as List;
      postos.value = postosData.map((e) => GasStationModel.fromMap(e)).toList();
      postosMap.value = {for (var p in postosData) p['pk_posto'].toString(): p};

      final tiposData = results[3] as List;
      tipos.value = tiposData.map((e) => TypeGasModel.fromMap(e)).toList();
      tiposMap.value = {for (var t in tiposData) t['pk_tipo'].toString(): t};

      final fuelData = results[4] as List;
      fuelEntries.value = fuelData.map((e) => FuelEntryModel.fromMap(e)).toList();

      
    } catch (e) {
      debugPrint("Erro na inicialização: $e");
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> saveFuel(Map<String, dynamic> data) async {
    try {
      await _supabase.from('abastecimentos').insert(data);
      Get.back(result: true);
    } catch (e) {
      _showSnackbar('Erro', 'Falha ao salvar', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFuel(FuelEntryModel model) async {
    try {
      if (model.id == null) return;
      isLoading.value = true;

      await _supabase
          .from('abastecimentos')
          .update(model.toMap())
          .eq('pk_fuel', model.id!);
      Get.back(result: true);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao atualizar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFuel(String id) async {
    try {
      await _supabase.from('abastecimentos').delete().eq('pk_fuel', id);
      fuelEntries.removeWhere((element) => element.id == id);
      _showSnackbar("Sucesso", "Item removido com sucesso!");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível deletar", isError: true);
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

      int index = vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        var v = vehicles[index];
        vehicles[index] = VehicleModel(
          id: v.id,
          nickname: v.nickname,
          plate: v.plate,
          city: v.city,
          make: v.make,
          model: v.model,
          fuelType: v.fuelType,
          year: v.year,
          initialOdometer: newOdometer,
          tankCapacity: v.tankCapacity,
        );
        vehicles.refresh();

        fetchInitialData();
      }
    } catch (e) {
      print("Erro ao atualizar odômetro do veículo: $e");
    }
  }

  Future<void> shareEntry(String entryId, List<String> userIds) async {
    try {
      await _supabase
          .from('abastecimentos')
          .update({'shared_with': userIds})
          .eq('pk_fuel', entryId);
      await fetchInitialData();
      _showSnackbar("Sucesso", "Compartilhamento atualizado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao compartilhar", isError: true);
    }
  }

  double getLatestOdometerForVehicle(dynamic vehicleId) {
    try {
      final lastEntry = fuelEntries.firstWhereOrNull(
        (e) => e.vehicleId == vehicleId,
      );
      if (lastEntry != null) {
        return lastEntry.odometerKm;
      }
      final vehicle = vehicles.firstWhereOrNull((v) => v.id == vehicleId);
      return vehicle?.initialOdometer ?? 0.0;
    } catch (e) {
      final veiculoData = veiculosMap[vehicleId];
      return (veiculoData?['initial_odometer'] as num? ?? 0.0).toDouble();
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
        final nomePosto = dadosPosto?['nome']?.toString().toLowerCase() ?? '';
        final dadosVeiculo = veiculosMap[e.vehicleId];
        final nomeVeiculo =
            dadosVeiculo?['nickname']?.toString().toLowerCase() ?? '';

        final dadosTipo = veiculosMap[e.fuelTypeId];
        final nomeTipo = dadosTipo?['nome']?.toString().toLowerCase() ?? '';

        return nomePosto.contains(query) ||
            nomeVeiculo.contains(query) ||
            nomeTipo.contains(query);
      }).toList();
    }
    return list;
  }

  
  List<FuelEntryModel> get meusAbastecimentos{
    final uid = _supabase.auth.currentUser?.id;
    return filteredFuelEntries.where((entry) => entry.user == uid).toList();
  }

  List<FuelEntryModel> get fuelEntriesCompartilhados {
    final uid = _supabase.auth.currentUser?.id;
    return filteredFuelEntries.where((entry) => entry.user != uid).toList();
  }

  double get consumoMediaGeral {
    final entries = selectedVehicleID.value != null
    ? filteredFuelEntries.where((e) => e.vehicleId == selectedVehicleID.value).toList()
    : fuelEntries.toList();

    if (entries.length < 2) return 0.0;
    final atual = entries[0];
    final anterior = entries[1];

    final double distancia = atual.odometerKm - anterior.odometerKm;
    final double litros = atual.volumeLiters;

    return distancia / litros;
  }

  double get custoMedioGeral {
    final entries = selectedVehicleID.value != null
    ? filteredFuelEntries.where((e) => e.vehicleId == selectedVehicleID.value).toList()
    : fuelEntries.toList();

    if (entries.isEmpty) return 0.0;
    double totalCusto = entries.fold(
      0,
      (sum, item) => sum + item.totalCost,
    );
    double totalKm =
        entries.first.odometerKm - (vehicles.first.initialOdometer);

    return totalKm > 0 ? totalCusto / totalKm : 0.0;
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
    final String nickname = vehicleInfo?['nickname'] ?? vehicleInfo?['modelo'] ?? "Veiculo";
    final double totalCap = (vehicleInfo?['tank_capacity'] as num? ?? 0.0).toDouble();

    String consumoNoTrajeto = "---";
    if(vehicleEntries.length >= 2){
      double media = last.calculateConsumption(vehicleEntries[1]);
      consumoNoTrajeto = "${media.toStringAsFixed(2)} km/L";
    }

    return {
      'vehicleName': nickname,
      'tank': totalCap.toString(),
      'displayRange': currentLevel > 0 ? currentLevel.toStringAsFixed(1) : "---",
      'level': currentLevel.toString(),
      'consumptionValue': consumoNoTrajeto,
      'message': currentLevel <= 5.0 ? "Reserva Critica!" : "Nível Baixo",
      'distanceUnit': 'L',      
    };
  }

  void mostrarCompartilhar(FuelEntryModel entry) {
    final meuId = _supabase.auth.currentUser?.id;
    Get.defaultDialog(
      title: "Compartilhar com...",
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: SingleChildScrollView(
          child: Obx(() {
            if (todosUsarios.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Nenhum usuário encontrado."),
              );
            }

            final listaFiltrada = todosUsarios
                .where((u) => u['id'] != meuId)
                .toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final user = listaFiltrada[index];
                final String userId = user['id']?.toString() ?? "";
                final String nomeUsuario =
                    user['nome']?.toString() ?? "Usuário sem nome";
                final String? fotoUrl = user['foto_url']?.toString();

                if (userId == meuId || userId.isEmpty) return SizedBox.shrink();
                final bool isShared = entry.sharedWith.contains(userId);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isShared ? Colors.green.shade200 : null,
                    backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: Icon(
                      RemixIcons.user_3_line,
                      color: isShared ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(
                    nomeUsuario,
                    style: TextStyle(
                      fontWeight: isShared
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isShared ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(""),
                  onTap: () {
                    List<String> novaLista = List<String>.from(
                      entry.sharedWith,
                    );
                    if (isShared) {
                      novaLista.remove(userId);
                    } else {
                      novaLista.add(userId);
                    }
                    shareEntry(entry.id!, novaLista);
                    Get.back();
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void navigateToAddEntry(BuildContext context) async {
    final result = await Get.to(() => HomeEntryPage());
    if (result == true) {
      _showSnackbar("Sucesso", "Abastecimento registrado!");
      fetchInitialData();
    }
  }

  void navigateToEditEntry(BuildContext context, FuelEntryModel entry) async {
    double odometerToSend = getLatestOdometerForVehicle(entry.vehicleId);

    final result = await Get.to(
      () => HomeEntryPage(lastOdometer: odometerToSend, entry: entry),
      arguments: entry,
    );
    if (result == true) {
      _showSnackbar("Sucesso", "Registro atualizado!");
      fetchInitialData();
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
