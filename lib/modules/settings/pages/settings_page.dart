import 'package:flutter/material.dart';
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
              Obx(() => Column(
                children: [
                  ListTile(
                    title: Text("Final da Placa"),
                    trailing: DropdownButton<int>(
                      value: controller.placaFinal.value,
                      items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                      onChanged: (val) => controller.setPlacaFinal(val!),
                    ),
                  ),
                  Divider(),
                  Text("Calendário IPVA 2026", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...controller.obterDatasVencimento().asMap().entries.map((entry){
                    return ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text("${entry.key + 1}ª Parcela / Cota Única"),
                      trailing: Text(entry.value),
                    );
                  }).toList(),
                ],
              )),
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
