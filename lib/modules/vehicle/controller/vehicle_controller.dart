import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final vehiclesMap = <dynamic, Map<String, dynamic>>{}.obs;
  var selectedVehicleID = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchVehicle();
  }

  Future<void> fetchVehicle() async {
    try {
      isLoading.value = true;
      final List<dynamic> data = await _supabase.from('veiculos').select();
      final Map<String, Map<String, dynamic>> tempMap = {};
      for (var item in data) {
        tempMap[item['id']] = item;
      }

      vehiclesMap.assignAll(tempMap);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao carregar os veículos: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveVeiculo(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('veiculos')
          .insert(data)
          .select()
          .single();
      final int idGerado = response['id'];
      vehiclesMap[idGerado] = response;
      vehiclesMap.refresh();

      _showSnackbar("Sucesso", "Veículo ${data['nickname']} guardado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVeiculo(VehicleModel veiculo) async {
    if (veiculo.id == null) {
      _showSnackbar("Erro", "ID não encontrado", isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final data = veiculo.toMap();
      await _supabase.from('veiculos').update(data).eq('id', veiculo.id!);
      
      vehiclesMap[veiculo.id] = data;
      vehiclesMap.refresh();

      Get.back();
      _showSnackbar("Sucesso", "Veículo ${data['nickname']} atualizado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVeiculo(dynamic id) async {
    try {
      await _supabase.from('veiculos').delete().eq('id', id);
      vehiclesMap.remove(id);
      vehiclesMap.refresh();

      Get.back();
      _showSnackbar("Eliminado", "O veículo foi removido.");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível eliminar: $e", isError: true);
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
