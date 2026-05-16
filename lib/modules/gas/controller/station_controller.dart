import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/station_model.dart';
import 'package:fuel_tracker_app/modules/registro/pages/station_entry_screen.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StationController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final settings = Get.find<SettingController>();

  // Observáveis
  var postos = <StationModel>[].obs;
  final isLoading = false.obs;
  final gasStationsMap = <dynamic, Map<String, dynamic>>{}.obs;
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

      gasStationsMap.assignAll(tempMap);
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
      await _supabase.from('postos').insert(data);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePosto(StationModel posto) async {
    try {
      if(posto.id == null) return;
      isLoading.value = true;
      await _supabase.from('postos').update(posto.toMap()).eq('pk_posto', posto.id!);
      
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePosto(dynamic id) async {
    try {
      await _supabase.from('postos').delete().eq('pk_posto', id);
      postos.removeWhere((element) => element.id == id);
      _showSnackbar("Eliminado", "O posto foi removido.");
    } catch (e) {
      _showSnackbar("Erro", "Não foi possível eliminar: $e", isError: true);
    }
  }

  void navigateToAddStation(BuildContext context) async {
    final result = await Get.toNamed('/station_entry');
    if (result == true) {
      _showSnackbar("Sucesso", "Posto Registrado!");
      fetchPosto();
    }
  }

  void navigateToEditStation(StationModel entry) async {
    final result = await Get.toNamed('/station_entry', arguments: entry);

    if (result == true) {
      _showSnackbar("Sucesso", "Posto atualizado!");
      fetchPosto();
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
