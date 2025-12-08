import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  Database? _database;

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
          TranslationKeys.backupRestoreErrorDbNotOpen,
          parameters: {'error': e.toString()},
        ),
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllDataFromDb() async {
    if (_database == null) {
      throw Exception(context.tr(TranslationKeys.backupRestoreErrorDbNotInitialized));
    }

    final allData = <String, List<Map<String, dynamic>>>{};

    for (final tableName in DatabaseHelper.tableNames) {
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

  Future<void> _insertAllDataIntoDb(Map<String, dynamic> data) async {
    if (_database == null) {
      throw Exception(context.tr(TranslationKeys.backupRestoreErrorDbNotInitialized));
    }

    await _database!.transaction((txn) async {
      for (final tableName in DatabaseHelper.tableNames) {
        final List<Map<String, dynamic>> tableEntries = List<Map<String, dynamic>>.from(
          data[tableName] ?? [],
        );

        if (tableEntries.isNotEmpty) {
          await txn.delete(tableName);
          for (var entry in tableEntries) {
            entry.remove('id');
            await txn.insert(tableName, entry, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    });
  }

  Future<void> _exportData() async {
    if (_database == null || !_database!.isOpen) {
      setState(() {
        _statusMessage = context.tr(TranslationKeys.backupRestoreErrorDbNotOpen);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final allData = await _fetchAllDataFromDb();
      final jsonString = jsonEncode(allData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final fileName = 'Fuel-Backup-($timestamp).json';
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
          TranslationKeys.backupRestoreExportSuccessPrefix,
          parameters: {'fileName': fileName},
        );
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(
          TranslationKeys.backupRestoreErrorExport,
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
        _statusMessage = context.tr(TranslationKeys.backupRestoreErrorDbNotOpen);
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
          _statusMessage = context.tr(TranslationKeys.backupRestoreImportNoFileSelected);
        });
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      await _insertAllDataIntoDb(data);

      setState(() {
        _statusMessage = context.tr(TranslationKeys.backupRestoreImportSuccess);
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(
          TranslationKeys.backupRestoreErrorImport,
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
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.backgroundColorDark
          : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.backupRestoreAppBarTitle)),
        backgroundColor: theme.brightness == Brightness.dark
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCard(
              title: context.tr(TranslationKeys.backupRestoreExportCardTitle),
              subtitle: context.tr(TranslationKeys.backupRestoreExportCardDescription),
              buttonText: context.tr(TranslationKeys.backupRestoreExportButton),
              theme: theme,
              context: context,
              isDbReady: isDbReady,
              onPressed: () => _exportData(),
            ),
            const SizedBox(height: 16),
            buildCard(
              title: context.tr(TranslationKeys.backupRestoreImportCardTitle),
              subtitle: context.tr(TranslationKeys.backupRestoreImportCardDescription),
              buttonText: context.tr(TranslationKeys.backupRestoreImportButton),
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
    return Card(
      color: theme.brightness == Brightness.dark ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: theme.brightness == Brightness.dark
                    ? AppTheme.textLightGrey
                    : AppTheme.textDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_isLoading || !isDbReady) ? null : onPressed,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
