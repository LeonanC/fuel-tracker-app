import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BackupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _box = GetStorage();

  var isLoading = false.obs;
  var statusMessage = RxnString();

  final Map<String, String> scopeToCollection = {
    'fuel_entries': 'fuels',
    'manutencao': 'service_type',
    'tipo_combustivel': 'tipo_combustivel',
    'vehicles': 'veiculos',
    'lookups': 'postos',
  };

  var selectedScopes = {
    'fuels': true,
    'service_type': true,
    'tipo_combustivel': true,
    'veiculos': true,
    'postos': true,
  }.obs;

  void toggleScope(String scope) {
    if (selectedScopes.containsKey(scope)) {
      selectedScopes[scope] = !selectedScopes[scope]!;
    }
  }

  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user == null) {
      statusMessage.value = "Usuário não encontrado.";
      return;
    }

    try {
      isLoading.value = true;
      statusMessage.value = "Iniciando backup na nuvem...";

      for (var scope in selectedScopes.entries) {
        if (scope.value) {
          await _uploadCollection(scope.key, user.uid);
        }
      }

      statusMessage.value = "Nuvem atualizada com sucesso!";
    } catch (e) {
      statusMessage.value = "Erro ao sincronização: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _uploadCollection(String scope, String uid) async {
    final collectionName = scopeToCollection[scope];
    if (collectionName == null) return;

    List<dynamic> localData = _box.read(collectionName) ?? [];
    if (localData.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (var item in localData) {
      String docId =
          item['pk_fuel']?.toString() ??
          item['pk_posto'] ??
          item['pk_service'] ??
          item['pk_tipo'] ??
          item['pk_vehicle'] ??
          DateTime.now().microsecondsSinceEpoch.toString();

      DocumentReference docRef = _firestore
          .collection('usuarios')
          .doc(uid)
          .collection(collectionName)
          .doc(docId);

      Map<String, dynamic> dataToUpload = Map<String, dynamic>.from(item);
      dataToUpload['fk_usuario'] = uid;
      dataToUpload['last_sync'] = FieldValue.serverTimestamp();

      batch.set(docRef, dataToUpload, SetOptions(merge: true));
      count++;

      if (count >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) await batch.commit();
  }

  Future<void> clearCloudData() async {
    final user = _auth.currentUser;
    if (user == null) {
      statusMessage.value = "Faça login para gerenciar em nuvem.";
      return;
    }

    try {
      isLoading.value = true;
      statusMessage.value = "Removendo dados selecionados...";

      int count = 0;
      WriteBatch batch = _firestore.batch();

      for (var entry in selectedScopes.entries) {
        if (entry.value) {
          final collectionName = scopeToCollection[entry.key];
          if (collectionName == null) continue;

          final snapshots = await _firestore
              .collection(collectionName)
              .where('fk_usuario', isEqualTo: user.uid)
              .get();

          for (var doc in snapshots.docs) {
            batch.delete(doc.reference);
            count++;

            if (count >= 450) {
              await batch.commit();
              batch = _firestore.batch();
              count = 0;
            }
          }
        }
      }

      if (count > 0) await batch.commit();

      statusMessage.value = "Limpeza concluída com sucesso.";
    } catch (e) {
      statusMessage.value = "Erro ao limpar dados: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
