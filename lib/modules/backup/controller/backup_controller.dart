import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _box = GetStorage();

  var isLoading = false.obs;
  var statusMessage = RxnString();

  final Map<String, String> scopeToCollection = {
    'abastecimentos': 'fuel_entries',
    'service_type': 'service_type',
    'tipo_combustivel': 'tipo_combustivel',
    'veiculos': 'vehicles',
    'postos': 'postos',
  };

  var selectedScopes = {
    'abastecimentos': true,
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
    final user = _supabase.auth.currentUser;
    if (user == null) {
      statusMessage.value = "Usuário não encontrado.";
      return;
    }

    try {
      isLoading.value = true;
      statusMessage.value = "Iniciando sincronização com Supabase...";

      for (var scope in selectedScopes.entries) {
        if (scope.value) {
          await _uploadToSupabase(scope.key, user.id);
        }
      }

      statusMessage.value = "Dados sincronizados com sucesso!";
    } catch (e) {
      statusMessage.value = "Erro ao sincronização: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _uploadToSupabase(String scope, String uid) async {
    final tableName = scopeToCollection[scope];
    if (tableName == null) return;

    List<dynamic> localData = _box.read(scope) ?? [];
    if (localData.isEmpty) return;

    final List<Map<String, dynamic>> dataToUpsert = localData.map((item) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(item);
      if (tableName == 'fuel_entries') {
        map['fk_usuario'] = uid;
      } else {
        map['user_id'] = uid;
      }

      map.remove('last_sync');
      return map;
    }).toList();

    await _supabase.from(tableName).upsert(dataToUpsert);
  }

  Future<void> clearCloudData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      statusMessage.value = "Faça login para gerenciar os dados.";
      return;
    }

    try {
      isLoading.value = true;
      statusMessage.value = "Removendo dados da nuvem...";

      for (var entry in selectedScopes.entries) {
        if (entry.value) {
          final tableName = scopeToCollection[entry.key];
          if (tableName == null) continue;

          final userColumn = (tableName == 'fuel_entries')
              ? 'fk_usuario'
              : 'user_id';

          await _supabase.from(tableName).delete().eq(userColumn, user.id);
        }
      }


      statusMessage.value = "Limpeza concluída com sucesso.";
    } catch (e) {
      statusMessage.value = "Erro ao limpar dados: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
