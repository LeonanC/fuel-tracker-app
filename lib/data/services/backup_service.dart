import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/services_type_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final Map<String, Function> _modelFactories = {
    'abastecimentos': (data) => FuelEntryModel.fromMap(data),
    'postos': (data) => GasStationModel.fromMap(data),
    'service_type': (data) => ServicesTypeModel.fromMap(data),
    'tipo_combustivel': (data) => TypeGasModel.fromMap(data),
    'veiculos': (data) => VehicleModel.fromMap(data),
  };

  Future<void> exportarBackup({List<String>? colecoes}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final listaParaProcessar = colecoes ?? _modelFactories.keys.toList();

    Map<String, dynamic> backupTotal = {
      'user_id': user.id,
      'data_exportacao': DateTime.now().toIso8601String(),
      'colecoes_incluidas': listaParaProcessar,
    };

    try {
      for (String tabela in listaParaProcessar) {
        final List<dynamic> data = await _supabase.from(tabela).select();

        backupTotal[tabela] = data.map((item) {
          final factory = _modelFactories[tabela];
          if(factory == null){
            throw Exception('A tabela "$tabela" não possui um mapeamento em _modelFactories. Verifique os nomes');
          }
          final model = factory(item);
          return model.toMap();
        }).toList();
      }
      await _salvarCompartilhar(jsonEncode(backupTotal), user.id);

    } catch (e) {
      debugPrint('Erro ao gerar backup: $e');
    }
  }

  Future<void> importarBackup(BuildContext context) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);
      Map<String, dynamic> backupJson = jsonDecode(await file.readAsString());

      if (backupJson['user_id'] != user.id) {
        _mostrarErroValidacao(context);
        return;
      }

      _mostrarLoading(context);

      for (var tabela in _modelFactories.keys) {
        if (backupJson[tabela] == null) continue;

        List documentos = backupJson[tabela];

        for (var doc in documentos) {
          Map<String, dynamic> map = Map<String, dynamic>.from(doc);
          
          if(map.containsKey('user_id')) map['user_id'] = user.id;
          if(map.containsKey('fk_usuario')) map['fk_usuario'] = user.id;

          await _supabase.from(tabela).upsert(map);
        }
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao importar backup: $e');
    }
  }

  Future<void> deletarDados(
    BuildContext context, {
    List<String>? colecoes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    bool confirmar = await _mostrarConfirmacao(context);
    if (!confirmar) return;

    final listaParaDeletar = colecoes ?? _modelFactories.keys.toList();

    try {
      _mostrarLoading(context);

      for (String tabela in listaParaDeletar) {
        final column = (tabela == 'abastecimentos')  ? 'fk_usuario' : 'user_id';

        await _supabase.from(tabela).delete().eq(column, user.id);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos os dados foram removidos.')),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Erro ao apagar dados: $e');
    }
  }

  Future<void> _salvarCompartilhar(String conteudo, String uid) async {
    final diretorio = await getTemporaryDirectory();
    final dataAtual = DateTime.now().millisecondsSinceEpoch;
    final caminhoFicheiro =
        "${diretorio.path}/backup_fuel_tracker_${uid}_$dataAtual.json";

    File(caminhoFicheiro).writeAsStringSync(conteudo);
    await Share.shareXFiles([
      XFile(caminhoFicheiro),
    ], text: 'Meu Backup do Fuel Tracker');
  }

  Future<bool> _mostrarConfirmacao(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pagar todos os dados?'),
            content: Text(
              'Esta ação é irreversível e apagará todo o seu histórico de abastecimento e veículos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("CANCELAR"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("APAGAR", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _mostrarErroValidacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Falha na Validação'),
        content: Text(
          'Este arquivo de backup pertence a outra conta e não pode ser importado para este perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }
}
