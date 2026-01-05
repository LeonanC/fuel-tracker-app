import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/controllers/update_controller.dart';
import 'package:fuel_tracker_app/models/app_update.dart';
import 'package:fuel_tracker_app/controllers/language_controller.dart';
import 'package:fuel_tracker_app/screens/backup_restore_screen.dart';
import 'package:fuel_tracker_app/screens/gas_station_management_screen.dart';
import 'package:fuel_tracker_app/screens/language_settings_screen.dart';
import 'package:fuel_tracker_app/screens/notificationReminders_settings_screen.dart';
import 'package:fuel_tracker_app/screens/unit_settings_screen.dart';
import 'package:fuel_tracker_app/screens/vehicle_entry_screen.dart';
import 'package:fuel_tracker_app/screens/vehicle_management_screen.dart';
import 'package:fuel_tracker_app/services/export_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends GetView<FuelListController> {
  ToolsScreen({super.key});

  LanguageController get _langCtrl => Get.find<LanguageController>();
  UpdateController get _updateCtrl => Get.find<UpdateController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;

    return Directionality(
      textDirection: _langCtrl.textDirection,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(context.tr(TranslationKeys.toolsScreenAppBarTitle)),
          elevation: 0,
          centerTitle: false,
        ),
        body: Obx(() {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              if (_updateCtrl.latestUpdate.value != null)
                _buildUpdateCard(context, _updateCtrl.latestUpdate.value!, isDark),

              _buildSectionTitle(
                context.tr(TranslationKeys.commonLabelsSettings ?? "Configurações"),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenLanguageCardTitle),
                description: context.tr(TranslationKeys.toolsScreenLanguageCardDescription),
                icon: RemixIcons.global_line,
                onTap: () => Get.to(() => LanguageSettingsScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenUnitCardTitle),
                description: context.tr(TranslationKeys.toolsScreenUnitCardDescription),
                icon: RemixIcons.ruler_2_line,
                onTap: () => Get.to(() => UnitSettingsScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenNotificationCardTitle),
                description: context.tr(TranslationKeys.toolsScreenNotificationCardDescription),
                icon: RemixIcons.notification_3_line,
                onTap: () => Get.to(() => NotificationRemindersSettingsScreen()),
              ),

              _buildSectionTitle(context.tr(TranslationKeys.commonLabelsManagement ?? "Gestão")),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenGasStationManagementTitle),
                description: context.tr(TranslationKeys.toolsScreenGasStationManagementDescription),
                icon: RemixIcons.gas_station_line,
                onTap: () => Get.to(() => GasStationManagementScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys_5.vehiclesScreenTitle),
                description: context.tr(TranslationKeys_5.vehiclesScreenDescription),
                icon: RemixIcons.car_line,
                onTap: () => Get.to(() => VehicleManagementScreen()),
              ),
              _buildSectionTitle(context.tr(TranslationKeys.commonLabelsData ?? "Dados")),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenBackupCardTitle),
                description: context.tr(TranslationKeys.toolsScreenBackupCardDescription),
                icon: RemixIcons.database_2_line,
                onTap: () => Get.to(() => BackupRestoreScreen()),
              ),
              _buildToolCard(
                context,
                title: context.tr(TranslationKeys.toolsScreenFeedbackTitle),
                description: context.tr(TranslationKeys.toolsScreenFeedbackDescription),
                icon: RemixIcons.mail_send_line,
                onTap: () => _sendFeedback(),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _sendFeedback() {
    const subject = 'Feedback Fuel Tracker App';
    _launchUrl('mailto:LeonanC@outlook.com.br?subject=${Uri.encodeComponent(subject)}');
  }

  Widget _buildUpdateCard(BuildContext context, AppUpdate update, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      color: Colors.blue.withValues(alpha: isDark ? 0.2 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => update.url != null ? _launchUrl(update.url!) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(RemixIcons.rocket_2_fill, color: Colors.blue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(TranslationKeys.updateServiceUpdateAvailable),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${TranslationKeys.updateServiceNewVersion} ${update.version}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.blue[200] : Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(RemixIcons.download_cloud_2_line, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryFuelColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFuelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryFuelColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(RemixIcons.arrow_right_s_line, color: Colors.grey.withValues(alpha: 0.5)),
            ],
          ),
        ),
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
}
