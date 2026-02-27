import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/update_controller.dart';
import 'package:fuel_tracker_app/data/models/app_update.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/language_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/backup_restore_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/language_settings_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/notificationReminders_settings_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/unit_settings_screen.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/vehicle_entry_screen.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends GetView<FuelListController> {
  const ToolsScreen({super.key});

  LanguageController get _langCtrl => Get.find<LanguageController>();
  UpdateController get _updateCtrl => Get.find<UpdateController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: _langCtrl.textDirection,
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF010101) : const Color(0xFFf8F9FA),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120.0,
              elevation: 0,
              backgroundColor: isDark
                  ? Color(0xFF010101)
                  : const Color(0xFFf8F9FA),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  bottom: 16,
                ),
                centerTitle: false,
                title: Text(
                  context.tr(TranslationKeys.toolsScreenAppBarTitle),
                  style: GoogleFonts.lato(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_updateCtrl.latestUpdate.value != null)
                        _buildUpdateCard(
                          context,
                          _updateCtrl.latestUpdate.value!,
                          isDark,
                        ),

                      _buildGroup(
                        title: context.tr(
                          TranslationKeys.commonLabelsSettings ??
                              "Configurações",
                        ),
                        items: [
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys.toolsScreenLanguageCardTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys
                                  .toolsScreenLanguageCardDescription,
                            ),
                            icon: RemixIcons.global_line,
                            iconColor: Colors.blue,
                            onTap: () => Get.to(() => LanguageSettingsScreen()),
                          ),
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys.toolsScreenUnitCardTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys.toolsScreenUnitCardDescription,
                            ),
                            icon: RemixIcons.ruler_2_line,
                            iconColor: Colors.orange,
                            onTap: () => Get.to(() => UnitSettingsScreen()),
                          ),
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys.toolsScreenNotificationCardTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys
                                  .toolsScreenNotificationCardDescription,
                            ),
                            icon: RemixIcons.notification_3_line,
                            iconColor: Colors.redAccent,
                            onTap: () => Get.to(
                              () => NotificationRemindersSettingsScreen(),
                            ),
                          ),
                        ],
                      ),

                      _buildGroup(
                        title: context.tr(
                          TranslationKeys.commonLabelsManagement ?? "Gestão",
                        ),
                        items: [
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys
                                  .toolsScreenGasStationManagementTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys
                                  .toolsScreenGasStationManagementDescription,
                            ),
                            icon: RemixIcons.gas_station_line,
                            iconColor: Colors.green,
                            onTap: () {
                              print("Em Desenvolvimento");
                            },
                          ),
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys_5.vehiclesScreenTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys_5.vehiclesScreenDescription,
                            ),
                            icon: RemixIcons.car_line,
                            iconColor: Colors.indigo,
                            onTap: () {
                              print("Em Desenvolvimento");
                            },
                          ),
                        ],
                      ),

                      _buildGroup(
                        title: context.tr(
                          TranslationKeys.commonLabelsData ?? "Dados",
                        ),
                        items: [
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys.toolsScreenBackupCardTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys.toolsScreenBackupCardDescription,
                            ),
                            icon: RemixIcons.cloud_line,
                            iconColor: Colors.cyan,
                            onTap: () => Get.to(() => BackupRestoreScreen()),
                          ),
                          _buildListTile(
                            context,
                            title: context.tr(
                              TranslationKeys.toolsScreenFeedbackTitle,
                            ),
                            subtitle: context.tr(
                              TranslationKeys.toolsScreenFeedbackDescription,
                            ),
                            icon: RemixIcons.customer_service_2_line,
                            iconColor: Colors.teal,
                            onTap: () => _sendFeedback(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Versão 7.7.0",
                          style: GoogleFonts.lato(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _sendFeedback() {
    const subject = 'Feedback Fuel Tracker App';
    _launchUrl(
      'mailto:LeonanC@outlook.com.br?subject=${Uri.encodeComponent(subject)}',
    );
  }

  Widget _buildUpdateCard(BuildContext context, AppUpdate update, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade900, Colors.blue.shade800]
              : [Colors.blue.shade600, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(RemixIcons.rocket_2_fill, color: Colors.white, size: 30),
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
                  '${TranslationKeys.updateServiceNewVersion} ${update.version} já pode ser instalada.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.blue[200] : Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                update.url != null ? _launchUrl(update.url!) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("Atualizar"),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF010101) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!Get.isDarkMode)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(
        RemixIcons.arrow_right_s_line,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
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
