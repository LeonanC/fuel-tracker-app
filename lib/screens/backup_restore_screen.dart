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
      debugPrint(context.tr(TranslationKeys.backupRestoreErrorDbNotOpen, parameters: {'error': e.toString()}));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFuelFromDb() async {
    if (_database == null) throw Exception(context.tr(TranslationKeys.backupRestoreErrorDbNotInitialized));
    return await _database!.query('fuel_entries');
  }

  Future<void> _insertFuelFromDb(Map<String, dynamic> data) async {
    if (_database == null) throw Exception(context.tr(TranslationKeys.backupRestoreErrorDbNotInitialized));
    await _database!.transaction((txn) async {
      await txn.delete('fuel_entries');
      final fuelentry = List<Map<String, dynamic>>.from(
        data['fuel_entries'] ?? [],
      );
      for (var fuel in fuelentry) {
        fuel.remove('id');
        await txn.insert(
          'fuel_entries',
          fuel,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
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
      final fuelLists = await _fetchFuelFromDb();
      final data = {'fuel_entries': fuelLists};
      final jsonString = jsonEncode(data);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'Fuel-Entry-($timestamp).json';
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
        _statusMessage = context.tr(TranslationKeys.backupRestoreExportSuccessPrefix, parameters: {'fileName': fileName});
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(TranslationKeys.backupRestoreErrorExport, parameters: {'error': e.toString()});
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

      if(result == null || result.files.isEmpty){
        setState(() {
          _statusMessage = context.tr(TranslationKeys.backupRestoreImportNoFileSelected);
        });
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      await _insertFuelFromDb(data);
      
      setState(() {
        _statusMessage = context.tr(TranslationKeys.backupRestoreImportSuccess);
      });
    } catch (e) {
      setState(() {
        _statusMessage = context.tr(TranslationKeys.backupRestoreErrorImport, parameters: {'error': e.toString()});
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
    final isDbReady = _database != null && _database!.isOpen;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys.backupRestoreAppBarTitle)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.cardDark,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(TranslationKeys.backupRestoreExportCardTitle),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(TranslationKeys.backupRestoreExportCardDescription),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (_isLoading || !isDbReady)
                          ? null
                          : _exportData,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(context.tr(TranslationKeys.backupRestoreExportButton)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.cardDark,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(TranslationKeys.backupRestoreImportCardTitle),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(TranslationKeys.backupRestoreImportCardDescription),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (_isLoading || !isDbReady)
                          ? null
                          : _importData,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(context.tr(TranslationKeys.backupRestoreImportButton)),
                    ),
                  ],
                ),
              ),
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
}
