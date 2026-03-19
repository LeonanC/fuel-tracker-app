import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BackupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var statusMessage = RxnString();

  final Map<String, String> scopeToCollection = {
    'fuel_entries': 'fuels',
    'manutencao': 'service_type',
    'vehicles': 'veiculos',
    'lookups': 'postos',
  };

  var selectedScopes = {
    'fuel_entries': true,
    'manutencao': true,
    'vehicles': true,
    'lookups': true,
  }.obs;

  void toggleScope(String scope) {
    selectedScopes[scope] = !(selectedScopes[scope] ?? false);
  }

  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user == null) {
      statusMessage.value = "Usuário não encontrado.";
      return;
    }

    try {
      isLoading.value = true;
      statusMessage.value = "Sincronizando com o Firebase...";

      await Future.delayed(const Duration(seconds: 1));

      statusMessage.value = "Dados sincronizados em tempo real.";
    } catch (e) {
      statusMessage.value = "Erro ao sincronização: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCloudData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      statusMessage.value = "Removendo dados selecionados...";

      final batch = _firestore.batch();

      for (var entry in selectedScopes.entries) {
        if (entry.value) {
          final collection = scopeToCollection[entry.key]!;
          final snapshots = await _firestore
              .collection(collection)
              .where('fk_usuario', isEqualTo: user.uid)
              .get();

          for (var doc in snapshots.docs) {
            batch.delete(doc.reference);
          }
        }
      }

      await batch.commit();
      statusMessage.value = "Dados removidos da nuvem.";
    } catch (e) {
      statusMessage.value = "Erro ao limpar: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
