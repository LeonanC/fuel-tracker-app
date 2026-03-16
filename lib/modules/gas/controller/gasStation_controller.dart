import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class GasStationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final snapshot = await _firestore.collection('postos').get();

      final Map<dynamic, Map<String, dynamic>> tempMap = {};
      for (var doc in snapshot.docs) {
        tempMap[doc.id] = doc.data();
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

      int novoId = 1;
      if (postosMap.isNotEmpty) {
        final List<int> ids = postosMap.keys
            .map((e) => int.parse(e.toString()))
            .toList();
        novoId = ids.reduce((curr, next) => curr > next ? curr : next) + 1;
      }

      data['pk_posto'] = novoId;

      await _firestore.collection('postos').doc(novoId.toString()).set(data);
      postosMap[novoId] = data;
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
      _showSnackbar(
        "Erro",
        "ID do posto não encontrado para atualização",
        isError: true,
      );
      return;
    }
    try {
      isLoading.value = true;

      final docRef = _firestore.collection('postos').doc(posto.id.toString());
      final data = posto.toMap();
      data['pk_posto'] = posto.id;

      await docRef.set(data, SetOptions(merge: true));
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
      await _firestore.collection('postos').doc(id.toString()).delete();
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
