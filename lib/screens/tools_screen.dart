import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/provider/fuel_entry_provider.dart';
import 'package:fuel_tracker_app/provider/language_provider.dart';
import 'package:fuel_tracker_app/screens/Appearance_settings_screen.dart';
import 'package:fuel_tracker_app/screens/backup_restore_screen.dart';
import 'package:fuel_tracker_app/screens/currency_settings_screen.dart';
import 'package:fuel_tracker_app/screens/language_settings_screen.dart';
import 'package:fuel_tracker_app/screens/notificationReminders_settings_screen.dart';
import 'package:fuel_tracker_app/screens/unit_settings_screen.dart';
import 'package:fuel_tracker_app/services/export_service.dart';
import 'package:fuel_tracker_app/services/update_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  AppUpdate? _update;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateService();
    final update = await updateService.checkForUpdates();
    setState(() {
      _update = update;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(TrHelper.errorUrlFormat(context, url))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuelProvider = Provider.of<FuelEntryProvider>(context);
    final exportService = ExportService();

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: Text(context.tr(TranslationKeys.toolsScreenAppBarTitle)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_update != null) _buildUpdateCard(context, _update!),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenAppearanceTitle),
                  description: context.tr(TranslationKeys.toolsScreenAppearanceDescription),
                  icon: Icons.palette_outlined,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppearanceSettingsScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenLanguageCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenLanguageCardDescription),
                  icon: Icons.language,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSettingsScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenUnitCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenUnitCardDescription),
                  icon: Icons.straight,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UnitSettingsScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenCurrencyCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenCurrencyCardDescription),
                  icon: Icons.monetization_on,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CurrencySettingsScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenNotificationCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenNotificationCardDescription),
                  icon: Icons.notifications_active,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationRemindersSettingsScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenExportReportCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenExportReportCardDescription),
                  icon: Icons.table_chart,
                  onTap: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    final List<FuelEntry> entries = await fuelProvider.getAllEntriesForExport();
                    final String? errorMessage = await exportService.exportAndShareEntries(entries);

                    if (context.mounted) {
                      if (errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $errorMessage'), backgroundColor: Colors.red));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Relatório gerado! Escolha como compartilhar.'), backgroundColor: Colors.green));
                      }
                    }
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenBackupCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenBackupCardDescription),
                  icon: Icons.backup,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BackupRestoreScreen()));
                  },
                ),
                _buildToolCard(
                  context,
                  title: context.tr(TranslationKeys.toolsScreenClearAllDataCardTitle),
                  description: context.tr(TranslationKeys.toolsScreenClearAllDataCardDescription),
                  icon: Icons.delete_forever,
                  onTap: () {
                    _showConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr(TranslationKeys.dialogDeleteTitle)),
          content: Text(context.tr(TranslationKeys.dialogDeleteContent)),
          actions: [
            TextButton(
              child: Text(context.tr(TranslationKeys.dialogDeleteButtonCancel)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
              child: Text(context.tr(TranslationKeys.dialogDeleteButtonDelete)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final provider = Provider.of<FuelEntryProvider>(context, listen: false);
                await provider.clearAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage.isEmpty ? 'Todos os dados foram apagados com sucesso.' : 'Erro ao apagar dados: ${provider.errorMessage}'),
                    backgroundColor: provider.errorMessage.isEmpty ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpdateCard(BuildContext context, AppUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: AppTheme.cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.system_update, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Update Available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Theme.of(context).brightness == Brightness.dark ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primaryFuelColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppTheme.primaryFuelColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryFuelColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
