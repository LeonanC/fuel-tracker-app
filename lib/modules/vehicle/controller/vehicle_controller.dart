import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final vehicles = <VehicleModel>[].obs;
  final vehiclesMap = <dynamic, Map<String, dynamic>>{}.obs;
  final tipos = <TypeGasModel>[].obs;
  final tiposMap = <dynamic, Map<String, dynamic>>{}.obs;
  var selectedVehicleID = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchVehicle();
  }

  Future<void> fetchVehicle() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _supabase.from('veiculos').select(),
        _supabase.from('tipo_combustivel').select(),
      ]);

      final vehicleData = results[0] as List;
      vehicles.value = vehicleData.map((e) => VehicleModel.fromMap(e)).toList();
      vehiclesMap.value = {for (var v in vehicleData) v['id'].toString(): v};

      final tiposData = results[1] as List;
      tipos.value = tiposData.map((e) => TypeGasModel.fromMap(e)).toList();
      tiposMap.value = {for (var t in tiposData) t['pk_tipo'].toString(): t};
    } catch (e) {
      _showSnackbar("Erro", "Falha ao carregar os veículos: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveVeiculo(Map<String, dynamic> data) async {
    try {
      await _supabase.from('veiculos').insert(data);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVeiculo(VehicleModel veiculo) async {
    try {
      if (veiculo.id == null) return;
      isLoading.value = true;

      await _supabase
          .from('veiculos')
          .update(veiculo.toMap())
          .eq('id', veiculo.id!);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVeiculo(dynamic id) async {
    try {
      await _supabase.from('veiculos').delete().eq('id', id);
      vehicles.removeWhere((element) => element.id == id);
      _showSnackbar("Eliminado", "O veículo foi removido.");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível eliminar: $e", isError: true);
    }
  }

  void navigateToAddVehicle(BuildContext context) async {
    final result = await Get.toNamed('/vehicles_entry');
    if (result == true) {
      fetchVehicle();
      _showSnackbar("Sucesso", "Veículo registrado!");
    }
  }
  void navigateToEditVehicle(VehicleModel entry) async {
    final result = await Get.toNamed('/vehicles_entry', arguments: {'entry': entry});
    if (result == true) {
      fetchVehicle();
      _showSnackbar("Sucesso", "Registro atualizado!");
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
