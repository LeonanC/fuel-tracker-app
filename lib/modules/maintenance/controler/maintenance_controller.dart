import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class MaintenanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final manutencaoMap = <dynamic, Map<String, dynamic>>{}.obs;
  var selectedVeiculoID = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchManutencao();
  }

  Future<void> fetchManutencao() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('manutencao').get();
      final Map<dynamic, Map<String, dynamic>> tempMap = {};
      for (var doc in snapshot.docs) {
        tempMap[doc.id] = doc.data();
      }

      manutencaoMap.assignAll(tempMap);
    } catch (e) {
      _showSnackbar("Erro", "Falha ao carregar manutenção: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMaintenance(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      int novoId = 1;
      if (manutencaoMap.isNotEmpty) {
        final List<int> ids = manutencaoMap.keys
            .map((e) => int.parse(e.toString()))
            .toList();
        novoId = ids.reduce((curr, next) => curr > next ? curr : next) + 1;
      }

      data['pk_service'] = novoId;

      await _firestore
          .collection('manutencao')
          .doc(novoId.toString())
          .set(data);
      manutencaoMap[novoId] = data;
      manutencaoMap.refresh();

      Get.back();
      _showSnackbar("Sucesso", "Manutenção ${data['nome']} guardado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMaintenance(MaintenanceModel maintenance) async {
    if (maintenance.id == null) {
      _showSnackbar(
        "Erro",
        "ID de manutencão não encontrado para atualização",
        isError: true,
      );
      return;
    }
    try {
      isLoading.value = true;

      final docRef = _firestore
          .collection('manutencao')
          .doc(maintenance.id.toString());
      final data = maintenance.toMap();
      data['pk_service'] = maintenance.id;

      await docRef.set(data, SetOptions(merge: true));
      manutencaoMap[maintenance.id] = data;
      manutencaoMap.refresh();

      Get.back();
      _showSnackbar("Sucesso", "Manutenção ${data['nome']} atualizado!");
    } catch (e) {
      _showSnackbar("Erro", "Falha ao salvar: $e", isError: true);
    } finally {
      isLoading.value = false;
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
