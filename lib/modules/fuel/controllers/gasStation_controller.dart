import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class GasStationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observáveis
  final _fuelEntries = <GasStationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final postosMap = <dynamic, Map<String, dynamic>>{}.obs;

  var selectedPostoID = Rxn<dynamic>();

  List<GasStationModel> get fuelEntries => _fuelEntries;

  Future<Map<String, dynamic>> getCurrentAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "Endereço não encontrado";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address =
            "${place.thoroughfare}, ${place.subThoroughfare}, ${place.subLocality}, ${place.locality}";
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };
    } catch (e) {
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': "Erro ao obter localização",
      };
    }
  }

  Future<void> saveOrUpdate(GasStationModel posto) async {
    try {
      isLoading.value = true;

      var collection = _firestore.collection('postos');
      int idFinal = posto.id!;

      if (idFinal == 0) {
        final idsExistentes = postosMap.values
            .map((p) => int.tryParse(p['pk_posto']?.toString() ?? '0') ?? 0)
            .toList();

        idFinal = idsExistentes.isEmpty
            ? 1
            : idsExistentes.reduce((a, b) => a > b ? a : b) + 1;

        final postoComId = GasStationModel(
          id: idFinal,
          nome: posto.nome,
          brand: posto.brand,
          address: posto.address,
          latitude: posto.latitude,
          longitude: posto.longitude,
          price: posto.price,
          hasConvenientStore: posto.hasConvenientStore,
          is24Hours: posto.is24Hours,
        );

        await collection
            .doc(idFinal.toString())
            .set(postoComId.toMap(), SetOptions(merge: true));

        postosMap[idFinal] = postoComId.toMap();
      } else {
        await collection
            .doc(posto.id.toString())
            .set(posto.toMap(), SetOptions(merge: true));

        postosMap[posto.id] = posto.toMap();
      }

      postosMap.refresh();
      Get.snackbar(
        "Sucesso",
        "Posto ${posto.nome} salvo com sucesso!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Falha ao salva/atualizar: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePosto(dynamic id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('postos').doc(id.toString()).delete();
      postosMap.remove(id);
      postosMap.refresh();

      Get.snackbar(
        "Excluído",
        "Posto removido com sucesso!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Não foi possível excluir: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
