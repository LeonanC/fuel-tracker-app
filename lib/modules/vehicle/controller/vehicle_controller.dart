import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class VehicleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final snapshot = await _firestore.collection('veiculos').get();
      final Map<String, Map<String, dynamic>> tempMap = {};
      for (var doc in snapshot.docs) {
        tempMap[doc.id] = doc.data();
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

      int novoId = 1;
      if (vehiclesMap.isNotEmpty) {
        final List<int> ids = vehiclesMap.keys
            .map((e) => int.parse(e.toString()))
            .toList();
        novoId = ids.reduce((curr, next) => curr > next ? curr : next) + 1;
      }

      data['pk_vehicle'] = novoId;

      await _firestore.collection('veiculos').doc(novoId.toString()).set(data);
      vehiclesMap[novoId] = data;
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
      _showSnackbar(
        "Erro",
        "ID do veículo não encontrado para atualização",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      final docRef = _firestore
          .collection('veiculos')
          .doc(veiculo.id.toString());
      final data = veiculo.toMap();
      data['pk_vehicle'] = veiculo.id;

      await docRef.set(data, SetOptions(merge: true));
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
      await _firestore.collection('veiculos').doc(id.toString()).delete();
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
