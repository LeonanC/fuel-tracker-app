import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/update_controller.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/screens/backup_restore_screen.dart';
import 'package:fuel_tracker_app/screens/gas_station_management_screen.dart';
import 'package:fuel_tracker_app/screens/language_settings_screen.dart';
import 'package:fuel_tracker_app/screens/notificationReminders_settings_screen.dart';
import 'package:fuel_tracker_app/screens/unit_settings_screen.dart';
import 'package:fuel_tracker_app/screens/vehicle_management_screen.dart';
import 'package:fuel_tracker_app/services/export_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends GetView<FuelListController> {
  ToolsScreen({super.key});

  final languageController = Get.find<LanguageController>();
  final updateController = Get.find<UpdateController>();
  final exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: languageController.textDirection,
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight,
        appBar: AppBar(
          title: Text(context.tr(TranslationKeys.toolsScreenAppBarTitle)),
          backgroundColor: theme.brightness == Brightness.dark
              ? AppTheme.backgroundColorDark
              : AppTheme.backgroundColorLight,
          elevation: 0,
          centerTitle: false,
        ),
        body: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (updateController.latestUpdate.value != null) 
                _buildUpdateCard(context, updateController.latestUpdate.value!),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenLanguageCardTitle.tr),
                description: context.tr(TranslationKeys.toolsScreenLanguageCardDescription.tr),
                icon: Icons.language,
                onTap: () => Get.to(() => LanguageSettingsScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenUnitCardTitle.tr),
                description: context.tr(TranslationKeys.toolsScreenUnitCardDescription.tr),
                icon: Icons.straight,
                onTap: () => Get.to(() => UnitSettingsScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenNotificationCardTitle.tr),
                description: context.tr(TranslationKeys.toolsScreenNotificationCardDescription.tr),
                icon: Icons.notifications_active,
                onTap: () => Get.to(() => NotificationRemindersSettingsScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenExportReportCardTitle),
                description: context.tr(TranslationKeys.toolsScreenExportReportCardDescription),
                icon: Icons.table_chart,
                onTap: () async {
                  Get.closeAllSnackbars();

                  final List<FuelEntry> entries = await controller.getAllEntriesForExport();
                  final String? errorMessage = await exportService.exportAndShareEntries(entries);

                  if (errorMessage != null) {
                    Get.snackbar(
                      'exportErrorTitle'.tr,
                      'exportError'.trParams({'error': errorMessage}),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'exportSuccessTitle'.tr,
                      'exportSuccessShare'.tr,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              _buildToolCard(
                context,
                title: 'Gerenciamento de Postos',
                description: 'Adicione, edite ou remova os postos de combustíveis.',
                icon: RemixIcons.gas_station_line,
                onTap: () => Get.to(() => GasStationManagementScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.vehiclesScreenTitle),
                description: context.tr(TranslationKeys.vehiclesScreenDescription),
                icon: Icons.directions_car_filled,
                onTap: () => Get.to(() => VehicleManagementScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenBackupCardTitle),
                description: context.tr(TranslationKeys.toolsScreenBackupCardDescription),
                icon: Icons.backup,
                onTap: () => Get.to(() => BackupRestoreScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenFeedbackTitle),
                description: context.tr(TranslationKeys.toolsScreenFeedbackDescription),
                icon: Icons.feedback_outlined,
                onTap: () {
                  final subject = 'Feedback%20Fuel%20Tracker%20App';
                  _launchUrl('mailto:LeonanC@outlool.com.br?subject=$subject');
                },
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenClearAllDataCardTitle),
                description: context.tr(TranslationKeys.toolsScreenClearAllDataCardDescription),
                icon: Icons.delete_forever,
                onTap: () => _showConfirmationDialog(controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (Get.context != null) {
        Get.snackbar(
          'error'.tr,
          'errorUrlFormat'.trParams({'url': url}),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showConfirmationDialog(FuelListController fuelController) {
    Get.dialog(
      AlertDialog(
        title: Text(TranslationKeys.dialogDeleteTitle),
        content: Text(TranslationKeys.dialogDeleteContent),
        actions: [
          TextButton(
            child: Text(TranslationKeys.dialogDeleteButtonCancel),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
            child: Text(TranslationKeys.dialogDeleteButtonDelete),
            onPressed: () async {
              Get.back();
              await fuelController.clearAllData();
              Get.snackbar(
                fuelController.errorMessage.isEmpty ? 'success'.tr : 'error'.tr,
                fuelController.errorMessage.isEmpty
                    ? 'clearDataSuccess'.tr
                    : 'clearDataError'.trParams({'error': fuelController.errorMessage.value}),
                backgroundColor: fuelController.errorMessage.isEmpty ? Colors.green : Colors.red,
              );
            },
          ),
        ],
      ),
      barrierDismissible: true,
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
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.system_update, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Update Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${TranslationKeys.updateServiceNewVersion.tr} ${update.version}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
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

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.cardDark
          : AppTheme.cardLight,
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
                decoration: BoxDecoration(
                  color: AppTheme.primaryFuelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryFuelColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
