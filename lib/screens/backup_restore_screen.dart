import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/backup_controller.dart';
import 'package:fuel_tracker_app/data/database_helper.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
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

class BackupRestoreScreen extends GetView<BackupController> {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        title: Text(context.tr(TranslationKeys_2.backupRestoreAppBarTitle)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr(TranslationKeys_2.backupRestoreScopeTitle)),
            const SizedBox(height: 24),
            _buildActionCard(
              context,
              title: "Fazer Backup",
              description: "Cria um arquivo JSON com os dados selecionados.",
              buttonLabel: "Exportar Dados",
              icon: Icons.cloud_upload_outlined,
              onPressed: controller.exportData,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Restaurar Dados",
              description: "Substitui dados atuais pelo arquivo selecionado.",
              buttonLabel: "Importar Dados",
              icon: Icons.settings_backup_restore_outlined,
              onPressed: controller.importData,
              isWarning: true,
            ),
            const SizedBox(height: 20),
            Obx(() => controller.statusMessage.value != null
            ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryFuelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.statusMessage.value!,
                style: TextStyle(
                  color: AppTheme.primaryFuelColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
            : const SizedBox.shrink())
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
    bool isWarning = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, size: 40, color: AppTheme.primaryFuelColor),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(description),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWarning ? Colors.orange.shade800 : AppTheme.primaryFuelColor,
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                      : Text(buttonLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
