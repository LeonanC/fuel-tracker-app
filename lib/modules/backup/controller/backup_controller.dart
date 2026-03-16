import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BackupController extends GetxController {
  var isLoading = false.obs;
  var statusMessage = RxnString();
  var selectedGroupKey = 'all'.obs;
  Database? _database;

  final List<String> allTableNames = [
    'fuel_entries',
    'manutencao',
    'vehicles',
    'gas_stations',
    'fuel_types',
    'service_types',
  ];

  final Map<String, List<String>> scopeToTables = {
    'fuel_entries': ['fuel_entries'],
    'manutencao': ['manutencao'],
    'vehicles': ['vehicles'],
    'lookups': ['gas_stations', 'fuel_types', 'service_types'],
  };

  var selectedScopes = {
    'fuel_entries': true,
    'manutencao': true,
    'vehicles': true,
    'lookups': true,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await DatabaseHelper.instance.database;
    } catch (e) {
      statusMessage.value = "Erro ao conectar ao banco.";
    }
  }

  void toggleScope(String scope) {
    selectedScopes[scope] = !(selectedScopes[scope] ?? false);
  }

  Future<void> exportData() async {
    if (_database == null) return;

    try {
      isLoading.value = true;
      statusMessage.value = "Preparando dados...";

      Map<String, dynamic> backupPayload = {
        'version': '1.0',
        'export_date': DateTime.now().toIso8601String(),
        'data': <String, List<Map<String, dynamic>>>{},
      };

      for (var entry in selectedScopes.entries) {
        if (entry.value) {
          final tables = scopeToTables[entry.key] ?? [];
          for (var table in tables) {
            final List<Map<String, dynamic>> rows = await _database!.query(table);
            backupPayload['data'][table] = rows;
          }
        }
      }

      if ((backupPayload['data'] as Map).isEmpty) {
        statusMessage.value = "Selecione ao menos un item para backup.";
        return;
      }

      final jsonString = jsonEncode(backupPayload);
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final fileName = 'Fuel-${selectedGroupKey.value.toUpperCase()}-$timestamp.json';

      Directory? directory = Platform.isAndroid
          ? Directory('storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (Platform.isAndroid && !await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }

      final file = File('${directory!.path}/$fileName');
      await file.writeAsString(jsonString);

      statusMessage.value = "Backup salvo: $fileName";
    } catch (e) {
      statusMessage.value = "Erro ao exportar: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importData() async {
    if (_database == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;

      isLoading.value = true;
      statusMessage.value = "Restaurando dados...";

      final file = File(result.files.single.path!);
      final Map<String, dynamic> decoded = jsonDecode(await file.readAsString());

      if (!decoded.containsKey('data')) {
        throw "Arquivo de backup inválido.";
      }

      final Map<String, dynamic> data = decoded['data'];

      await _database!.transaction((txn) async {
        for (var tableName in data.keys) {
          await txn.delete(tableName);

          final List<dynamic> rows = data[tableName];

          for (var row in rows) {
            await txn.insert(
              tableName, 
              Map<String, dynamic>.from(row), 
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
      statusMessage.value = "Dados restaurados com sucesso!";
    } catch (e) {
      statusMessage.value = "Erro ao importar: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
