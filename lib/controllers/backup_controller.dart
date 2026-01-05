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

  late final Map<String, List<String>> tableGroups = {
    'all': allTableNames,
    'fuel_entries': ['fuel_entries'],
    'manutencao': ['manutencao'],
    'vehicles': ['vehicles'],
    'lookups': ['gas_stations', 'fuel_types', 'service_types'],
  };

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

  Future<void> exportData() async {
    if (_database == null) return;

    isLoading.value = true;
    statusMessage.value = null;

    try {
      final tables = tableGroups[selectedGroupKey.value]!;
      final Map<String, List<Map<String, dynamic>>> allData = {};

      for(var table in tables){
        allData[table] = await _database!.query(table);
      }

      final jsonString = jsonEncode(allData);
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final fileName = 'Fuel-${selectedGroupKey.value.toUpperCase()}-$timestamp.json';

      Directory? directory = Platform.isAndroid
        ? Directory('storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

      if(Platform.isAndroid && !await directory.exists()){
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
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if(result == null) return;

      isLoading.value = true;
      final file = File(result.files.single.path!);
      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final tables = tableGroups[selectedGroupKey.value]!;

      await _database!.transaction((txn) async {
        for(var table in tables){
          if(data.containsKey(table)){
            await txn.delete(table);
            for(var row in List<Map<String, dynamic>>.from(data[table])){
              final newRow = Map<String, dynamic>.from(row);
              await txn.insert(table, newRow, conflictAlgorithm: ConflictAlgorithm.replace);
            }
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