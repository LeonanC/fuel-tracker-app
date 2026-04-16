// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/services_type_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, Function> _modelFactories = {
    'fuels': (data, id) => FuelEntryModel.fromFirestore(data, id),
    'postos': (data, id) => GasStationModel.fromFirestore(data, id),
    'service_type': (data, id) => ServicesTypeModel.fromFirestore(data, id),
    'tipo_combustivel': (data, id) => TypeGasModel.fromFirestore(data, id),
    'veiculos': (data, id) => VehicleModel.fromFirestore(data, id),
  };

  dynamic _toJsonFormat(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) return value.map((k, v) => MapEntry(k, _toJsonFormat(v)));
    if (value is List) return value.map(_toJsonFormat).toList();
    return value;
  }

  Future<void> exportarBackup({List<String>? colecoes}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final listaParaProcessar = colecoes ?? _modelFactories.keys.toList();

    Map<String, dynamic> backupTotal = {
      'fk_usuario': user.uid,
      'data_exportacao': DateTime.now().toIso8601String(),
      'colecoes_incluidas': listaParaProcessar,
    };

    try {
      for (String colecao in listaParaProcessar) {
        if (!_modelFactories.containsKey(colecao)) continue;

        QuerySnapshot snapshot;
        if (colecao == 'fuels') {
          snapshot = await _db
              .collection(colecao)
              .where('fk_usuario', isEqualTo: user.uid)
              .get();
        } else {
          snapshot = await _db.collection(colecao).get();
        }

        backupTotal[colecao] = snapshot.docs.map((doc) {
          var model = _modelFactories[colecao]!(doc.data(), doc.id);
          var map = model.toMap();
          map['id_firestore'] = doc.id;
          return _toJsonFormat(map);
        }).toList();
      }

      await _salvarCompartilhar(jsonEncode(backupTotal), user.uid);
    } catch (e) {
      debugPrint('Erro ao gerar backup: $e');
    }
  }

  Future<void> importarBackup(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);
      Map<String, dynamic> backupJson = jsonDecode(await file.readAsString());

      if (backupJson['fk_usuario'] != user.uid) {
        _mostrarErroValidacao(context);
        return;
      }

      _mostrarLoading(context);

      for (var colecao in _modelFactories.keys) {
        if (backupJson[colecao] == null) continue;

        List documentos = backupJson[colecao];

        for (var doc in documentos) {
          Map<String, dynamic> map = Map<String, dynamic>.from(doc);
          String? idDocumento = map['id_firestore'];
          map.remove('id_firestore');
          map['fk_usuario'] = user.uid;

          var model = _modelFactories[colecao]!(map, idDocumento ?? '');

          if (idDocumento != null) {
            await _db.collection(colecao).doc(idDocumento).set(model.toMap());
          } else {
            await _db.collection(colecao).add(model.toMap());
          }
        }
      }
      Navigator.pop(context);
      _mostrarSucesso(context);
    } catch (e) {
      debugPrint('Erro ao importar backup: $e');
    }
  }

  Future<void> deletarDados(
    BuildContext context, {
    List<String>? colecoes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    bool confirmar = await _mostrarConfirmacao(context);
    if (!confirmar) return;

    final listaParaDeletar = colecoes ?? _modelFactories.keys.toList();

    try {
      _mostrarLoading(context);

      for (String nomeColecao in listaParaDeletar) {
        QuerySnapshot snapshot;
        if (nomeColecao == 'fuels') {
          snapshot = await _db
              .collection(nomeColecao)
              .where('fk_usuario', isEqualTo: user.uid)
              .get();
        } else {
          snapshot = await _db.collection(nomeColecao).get();
        }

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
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

  void _mostrarSucesso(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Dados restaurados com sucesso!')));
  }
}
