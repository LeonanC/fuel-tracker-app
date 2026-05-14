import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/backup/pages/backup_page.dart';
import 'package:fuel_tracker_app/modules/gas/pages/gas_station_screen.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/remider/pages/reminders_screen.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:fuel_tracker_app/modules/vehicle/pages/vehicle_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends GetView<SettingController> {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "cl_titulo".tr,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle('sp_aparencia'.tr, colorScheme.primary),
                Obx(
                  () => _buildSettingTile(
                    theme: theme,
                    icon: controller.isDarkMode.value
                        ? RemixIcons.moon_fill
                        : RemixIcons.sun_fill,
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

                const SizedBox(height: 25),

                _sectionTitle('cl_settings'.tr, colorScheme.primary),
                _buildSettingTile(
                  theme: theme,
                  title: 'sp_notification_title'.tr,
                  subtitle: 'sp_notification_desc'.tr,
                  icon: RemixIcons.notification_3_line,
                  onTap: () => Get.to(() => RemindersPages()),
                ),
                const SizedBox(height: 25),

                _sectionTitle('cl_management'.tr, colorScheme.primary),
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

                const SizedBox(height: 25),

                _sectionTitle('cl_dados'.tr, colorScheme.primary),

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
                const SizedBox(height: 40),
                _buildLogoutButton(theme),
                const SizedBox(height: 30),
                Obx(
                  () => Center(
                    child: Text(
                      "Versão ${controller.appVersion.value}",
                      style: GoogleFonts.firaCode(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'sp_selecione_idioma'.tr,
              style: GoogleFonts.montserrat(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 25),
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
        style: GoogleFonts.montserrat(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        controller.changeLanguage(langCode, countryCode);
        Get.back();
      },
    );
  }

  Widget _sectionTitle(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
        ),
        trailing:
            trailing ??
            Icon(
              RemixIcons.arrow_right_s_line,
              size: 18,
              color: theme.iconTheme.color?.withOpacity(0.2),
            ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    final perfilController = Get.find<PerfilController>();
    const logoutColor = Color(0xFFFB7185);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => perfilController.logout(),
        icon: Icon(
          RemixIcons.logout_circle_r_line,
          color: logoutColor,
          size: 20,
        ),
        label: Text(
          'SAIR DA CONTA',
          style: GoogleFonts.montserrat(
            color: logoutColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: logoutColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: logoutColor.withOpacity(0.2)),
          ),
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
