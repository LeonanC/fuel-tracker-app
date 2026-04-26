import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GasStationController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observáveis
  final isLoading = false.obs;
  final postosMap = <dynamic, Map<String, dynamic>>{}.obs;
  var selectedPostoID = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchPosto();
  }

  Future<void> fetchPosto() async {
    try {
      isLoading.value = true;
      final List<dynamic> data = await _supabase.from('postos').select();

      final Map<dynamic, Map<String, dynamic>> tempMap = {};
      for (var item in data) {
        tempMap[item['pk_posto']] = item;
      }

      postosMap.assignAll(tempMap);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao carregar postos: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {"error": "O GPS está desativado no seu telemóvel."};
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {"error": "Permissão de localização negada."};
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String formattedAddress =
            "${place.thoroughfare}, ${place.subThoroughfare} - ${place.subLocality}, ${place.subAdministrativeArea}";

        return {
          "address": formattedAddress,
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
      return {"error": "Endereço não encontrado."};
    } catch (e) {
      return {"error": "Erro ao obter localização: $e"};
    }
  }

  Future<void> savePosto(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('postos')
          .insert(data)
          .select()
          .single();
      final int idGerado = response['pk_posto'];
      postosMap[idGerado] = response;
      postosMap.refresh();

      Get.back();
      _showSnackbar("Sucesso", "Posto ${data['nome']} guardado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePosto(GasStationModel posto) async {
    if (posto.id == null) {
      _showSnackbar("Erro", "ID não encontrado", isError: true);
      return;
    }
    try {
      isLoading.value = true;

      final data = posto.toMap();
      await _supabase.from('postos').update(data).eq('pk_posto', posto.id!);

      postosMap[posto.id] = data;
      postosMap.refresh();

      Get.back();
      _showSnackbar("Sucesso", "Posto ${posto.nome} atualizado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePosto(dynamic id) async {
    try {
      await _supabase.from('postos').delete().eq('pk_posto', id);

      postosMap.remove(id);
      postosMap.refresh();

      _showSnackbar("Eliminado", "O posto foi removido.");
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
