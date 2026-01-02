import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class TranslationKeys_2 {
  static const String backupRestoreAppBarTitle = 'Título Backup/Restaurar';
  static const String backupRestoreExportCardTitle = 'Fazer Backup';
  static const String backupRestoreExportCardDescription =
      'Cria um arquivo JSON com os dados selecionados.';
  static const String backupRestoreExportButton = 'Exportar Dados';
  static const String backupRestoreImportCardTitle = 'Restaurar Dados';
  static const String backupRestoreImportCardDescription =
      'Substitui dados existentes no escopo selecionado.';
  static const String backupRestoreImportButton = 'Importar Dados';
  static const String backupRestoreErrorDbNotOpen = 'Erro: Banco de dados não aberto.';
  static const String backupRestoreErrorDbNotInitialized = 'Erro: Banco de dados não inicializado.';
  static const String backupRestoreErrorExport = 'Erro ao exportar: {error}';
  static const String backupRestoreExportSuccessPrefix = 'Sucesso! Aquivo salvo como {fileName}';
  static const String backupRestoreImportNoFileSelected = 'Nenhum arquivo selecionado.';
  static const String backupRestoreImportSuccess = 'Restauração concluída com sucesso!';
  static const String backupRestoreErrorImport = 'Erro ao importar: {error}';
  static const String backupRestoreScopeTitle = 'Escopo de Backup/Restauração';

  static const String scopeAll = 'Tudo (Completo)';
  static const String scopeFuelEntries = 'Abastecimentos';
  static const String scopeManutencao = 'Manutenções';
  static const String scopeVehicles = 'Veículos';
  static const String scopeLookups = 'Dados Auxiliares';
}

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  Database? _database;

  static const List<String> _allTableNames = [
    'fuel_entries',
    'manutencao',
    'vehicles',
    'gas_stations',
    'fuel_types',
    'service_types',
  ];

  late final Map<String, List<String>> _tableGroups = {
    'all': _allTableNames,
    'fuel_entries': ['fuel_entries'],
    'manutencao': ['manutencao'],
    'vehicles': ['vehicles'],
    'lookups': ['gas_stations', 'fuel_types', 'service_types'],
  };

  late String _selectedGroupKey = 'all';

  Map<String, String> get _scopeDisplayNames => {
    'all': context.tr(TranslationKeys_2.scopeAll),
    'fuel_entries': context.tr(TranslationKeys_2.scopeFuelEntries),
    'manutencao': context.tr(TranslationKeys_2.scopeManutencao),
    'vehicles': context.tr(TranslationKeys_2.scopeVehicles),
    'lookups': context.tr(TranslationKeys_2.scopeLookups),
  };

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final db = await DatabaseHelper.init();
      setState(() {
        _database = db;
      });
    } catch (e) {
      debugPrint(
        context.tr(
          TranslationKeys_2.backupRestoreErrorDbNotOpen,
          parameters: {'error': e.toString()},
        ),
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllDataFromDb(
    List<String> tableNames,
  ) async {
    if (_database == null) {
      throw Exception(context.tr(TranslationKeys_2.backupRestoreErrorDbNotInitialized));
    }

    final allData = <String, List<Map<String, dynamic>>>{};

    for (final tableName in tableNames) {
      try {
        final List<Map<String, dynamic>> tableData = await _database!.query(tableName);
        allData[tableName] = tableData;
      } catch (e) {
        debugPrint('Aviso: Não foi possível consular a tabela $tableName. $e');
        allData[tableName] = [];
      }
    }
    return allData;
  }

  Future<void> _insertAllDataIntoDb(Map<String, dynamic> data, List<String> tableNames) async {
    if (_database == null) {
      throw Exception(context.tr(TranslationKeys_2.backupRestoreErrorDbNotInitialized));
    }

    await _database!.transaction((txn) async {
      for (final tableName in tableNames) {
        final List<Map<String, dynamic>> tableEntries = List<Map<String, dynamic>>.from(
          data[tableName] ?? [],
        );

        if (tableEntries.isNotEmpty) {
          await txn.delete(tableName);
          for (var entry in tableEntries) {
            entry.remove('id');
            final entryToInsert = entry.map((k, v) => MapEntry(k.toString(), v));
            await txn.insert(
              tableName,
              entryToInsert,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    });
  }

  Future<void> _exportData() async {
    if (_database == null || !_database!.isOpen) {
      setState(() {
        _statusMessage = context.tr(TranslationKeys_2.backupRestoreErrorDbNotOpen);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final tableNamesToProcess = _tableGroups[_selectedGroupKey]!;

      final allData = await _fetchAllDataFromDb(tableNamesToProcess);
      final jsonString = jsonEncode(allData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');

      final fileName = 'Fuel-${_selectedGroupKey.toUpperCase()}-Backup-($timestamp).json';

      Directory? downloadsDir;
      try {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      } catch (e) {
        downloadsDir = await getTemporaryDirectory();
      }
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(jsonString);

      setState(() {
        _statusMessage = context.tr(
          TranslationKeys_2.backupRestoreExportSuccessPrefix,
          parameters: {'fileName': fileName},
        );
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(
          TranslationKeys_2.backupRestoreErrorExport,
          parameters: {'error': e.toString()},
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    if (_database == null || !_database!.isOpen) {
      setState(() {
        _statusMessage = context.tr(TranslationKeys_2.backupRestoreErrorDbNotOpen);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _statusMessage = context.tr(TranslationKeys_2.backupRestoreImportNoFileSelected);
        });
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final tableNamesToProcess = _tableGroups[_selectedGroupKey]!;
      await _insertAllDataIntoDb(data, tableNamesToProcess);

      setState(() {
        _statusMessage = context.tr(TranslationKeys_2.backupRestoreImportSuccess);
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(
          TranslationKeys_2.backupRestoreErrorImport,
          parameters: {'error': e.toString()},
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackupRestoreScreen(context);
  }

  Widget _buildBackupRestoreScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDbReady = _database != null && _database!.isOpen;
    final isDarkMode = theme.brightness == Brightness.dark
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    final textColor = theme.brightness == Brightness.dark ? AppTheme.textLight : AppTheme.textDark;

    return Scaffold(
      backgroundColor: isDarkMode,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys_2.backupRestoreAppBarTitle)),
        backgroundColor: isDarkMode,
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(TranslationKeys_2.backupRestoreScopeTitle),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryFuelColor, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroupKey,
                  isExpanded: true,
                  style: TextStyle(color: textColor, fontSize: 16),
                  dropdownColor: theme.brightness == Brightness.dark
                      ? AppTheme.cardDark
                      : AppTheme.cardLight,
                  icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryFuelColor),
                  items: _scopeDisplayNames.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGroupKey = newValue;
                        _statusMessage = null;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildCard(
              title: context.tr(TranslationKeys_2.backupRestoreExportCardTitle),
              subtitle:
                  '${context.tr(TranslationKeys_2.backupRestoreExportCardDescription)} (${_scopeDisplayNames[_selectedGroupKey]})',
              buttonText: context.tr(TranslationKeys_2.backupRestoreExportButton),
              theme: theme,
              context: context,
              isDbReady: isDbReady,
              onPressed: () => _exportData(),
            ),
            const SizedBox(height: 16),
            buildCard(
              title: context.tr(TranslationKeys_2.backupRestoreImportCardTitle),
              subtitle:
                  '${context.tr(TranslationKeys_2.backupRestoreImportCardDescription)} (${_scopeDisplayNames[_selectedGroupKey]})',
              buttonText: context.tr(TranslationKeys_2.backupRestoreImportButton),
              theme: theme,
              context: context,
              isDbReady: isDbReady,
              onPressed: () => _importData(),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains('Erro') || _statusMessage!.contains('Error')
                      ? Colors.red
                      : AppTheme.primaryFuelColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Card buildCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required ThemeData theme,
    required BuildContext context,
    required bool isDbReady,
    required Function() onPressed,
  }) {
    final cardColor = theme.brightness == Brightness.dark ? AppTheme.cardDark : AppTheme.cardLight;
    final primaryTextColor = theme.brightness == Brightness.dark
        ? AppTheme.textLight
        : AppTheme.textDark;
    final secondaryTextColor = theme.brightness == Brightness.dark
        ? AppTheme.textLightGrey
        : AppTheme.textDarkGrey;
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 14, color: secondaryTextColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_isLoading || !isDbReady) ? null : onPressed,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
