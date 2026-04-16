import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/backup/controller/update_controller.dart';
import 'package:fuel_tracker_app/data/models/app_update.dart';
import 'package:fuel_tracker_app/modules/backup/pages/backup_page.dart';
import 'package:fuel_tracker_app/modules/gas/pages/gas_station_screen.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/remider/pages/reminders_screen.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/vehicle/pages/vehicle_screen.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends GetView<SettingController> {
  const ToolsScreen({super.key});

  UpdateController get _updateCtrl => Get.find<UpdateController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "cl_titulo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_updateCtrl.latestUpdate.value != null)
                _buildUpdateCard(
                  context,
                  _updateCtrl.latestUpdate.value!,
                  theme,
                ),
              const SizedBox(height: 16),
              _sectionTitle('sp_aparencia'.tr),
              Obx(
                () => _buildSettingTile(
                  theme: theme,
                  icon: controller.isDarkMode.value
                      ? RemixIcons.moon_line
                      : RemixIcons.sun_line,
                  title: "sp_modo_escuro".tr,
                  subtitle: "sp_modo_escuro_sub".tr,
                  trailing: Switch(
                    value: controller.isDarkMode.value,
                    onChanged: (val) => controller.toggleTheme(),
                    activeColor: Colors.blueAccent,
                  ),
                ),
              ),
              _buildSettingTile(
                theme: theme,
                icon: RemixIcons.global_line,
                title: "sp_idioma".tr,
                subtitle: "sp_idioma_nome".tr,
                onTap: () => _showLanguageModal(context, theme),
              ),

              _sectionTitle('cl_settings'.tr),
              Obx(
                () => _buildSettingTile(
                  theme: theme,
                  icon: RemixIcons.ruler_2_line,
                  title: 'sp_unidade_distancia'.tr,
                  subtitle: 'sp_quilometros'.tr,
                  trailing: Switch(
                    value: controller.useMiles.value,
                    onChanged: controller.toggleUnit,
                    activeColor: Colors.blueAccent,
                  ),
                ),
              ),
              Obx(
                () => _buildSettingTile(
                  theme: theme,
                  icon: RemixIcons.drop_line,
                  title: 'sp_unidade_volume'.tr,
                  subtitle: 'sp_litros'.tr,
                  trailing: Switch(
                    value: controller.useVolume.value,
                    onChanged: controller.toggleVolume,
                    activeColor: Colors.orangeAccent,
                  ),
                ),
              ),
              _buildSettingTile(
                theme: theme,
                title: 'sp_notification_title'.tr,
                subtitle: 'sp_notification_desc'.tr,
                icon: RemixIcons.notification_3_line,
                onTap: () => Get.to(() => RemindersPages()),
              ),
              const SizedBox(height: 24),
              _sectionTitle('cl_management'.tr),
              _buildSettingTile(
                theme: theme,
                title: 'sp_gasStation_title'.tr,
                subtitle: 'sp_gasStation_desc'.tr,
                icon: RemixIcons.gas_station_line,
                onTap: () => Get.to(() => GasStationScreen()),
              ),
              _buildSettingTile(
                theme: theme,
                title: 'sp_vehicles_title'.tr,
                subtitle: 'sp_vehicles_desc'.tr,
                icon: RemixIcons.car_line,
                onTap: () => Get.to(() => VehicleScreen()),
              ),
              _sectionTitle('cl_dados'.tr),

              _buildSettingTile(
                theme: theme,
                title: 'sp_backup_title'.tr,
                subtitle: 'sp_backup_desc'.tr,
                icon: RemixIcons.cloud_line,
                onTap: () => Get.to(() => BackupRestoreScreen()),
              ),
              _buildSettingTile(
                theme: theme,
                title: 'sp_feedback_title'.tr,
                subtitle: 'sp_feedback_desc'.tr,
                icon: RemixIcons.customer_service_2_line,
                onTap: () => _sendFeedback(),
              ),
              const SizedBox(height: 30),
              _buildLogoutButton(theme),
              const SizedBox(height: 40),
              Obx(
                () => Center(
                  child: Text(
                    "Versão ${controller.appVersion.value}",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'sp_selecione_idioma'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _languageItem(theme, 'Português', 'pt', 'BR', "🇧🇷"),
            _languageItem(theme, 'English', 'en', "US", "🇺🇸"),
            _languageItem(theme, 'Español', 'es', "ES", "🇪🇸"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _languageItem(
    ThemeData theme,
    String nome,
    String langCode,
    String countryCode,
    String flag,
  ) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(
        nome,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: () {
        controller.changeLanguage(langCode, countryCode);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _sendFeedback() {
    const subject = 'Feedback Fuel Tracker App';
    _launchUrl(
      'mailto:LeonanC@outlook.com.br?subject=${Uri.encodeComponent(subject)}',
    );
  }

  Widget _buildUpdateCard(
    BuildContext context,
    AppUpdate update,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Color(0xFF1E3C72), Color(0xFF2A5298)]
              : [Colors.blue.shade700, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  RemixIcons.rocket_2_fill,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sp_update_available'.tr,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v${update.version} • ${'sp_ready_to_install'.tr}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _launchUrl(update.url),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "sp_update_new".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.blueAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
          ),
        ),
        trailing:
            trailing ??
            Icon(
              RemixIcons.arrow_right_s_line,
              size: 18,
              color: theme.iconTheme.color?.withOpacity(0.3),
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

  Widget _buildLogoutButton(ThemeData theme) {
    final perfilController = Get.find<PerfilController>();
    const logoutColor = Color(0xFFFB7185);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => perfilController.logout(),
        icon: Icon(RemixIcons.logout_box_r_line, color: logoutColor),
        label: const Text(
          'SAIR DA CONTA',
          style: TextStyle(color: logoutColor, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: logoutColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
