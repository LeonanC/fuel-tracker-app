import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class PerfilPage extends GetView<PerfilController> {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final homeController = Get.find<HomeController>();
    final settingsController = Get.find<SettingController>();

    final Color surfaceColor = theme.colorScheme.surfaceContainer;
    final Color backgroundColor = theme.colorScheme.surface;
    final Color textColor = theme.colorScheme.onSurface;
    final Color textSecondary = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppbar(textColor),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }
        final user = controller.userModel.value;
        if (user == null) return const SizedBox.shrink();
        final vehicleData = homeController.veiculosMap[user.vehicle] ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              _buildHeader(
                user.nome,
                user.email,
                user.fotoUrl,
                textColor,
                textSecondary,
                colorScheme.primary,
              ),
              const SizedBox(height: 25),
              _buildEfficiencyGrid(
                homeController,
                settingsController,
                surfaceColor,
              ),
              const SizedBox(height: 25),
              _buildDriverRankCard(
                surfaceColor,
                colorScheme.primary,
                textColor,
                textSecondary,
              ),
              const SizedBox(height: 25),
              _buildSectionHeader(
                "lg_veiculo_ativo".tr,
                RemixIcons.car_fill,
                colorScheme.primary,
              ),
              _buildDataCard(surfaceColor, [
                _buildDataRow(
                  RemixIcons.copyright_line,
                  "lg_marca".tr,
                  vehicleData['make'] ?? "---",
                  textColor,
                  textSecondary,
                ),
                _divider(colorScheme.outlineVariant),
                _buildDataRow(
                  RemixIcons.settings_3_line,
                  "lg_modelo".tr,
                  vehicleData['model'] ?? "---",
                  textColor,
                  textSecondary,
                ),
                _divider(colorScheme.outlineVariant),
                _buildDataRow(
                  RemixIcons.hashtag,
                  "lg_placa".tr,
                  vehicleData['plate'] ?? "---",
                  textColor,
                  textSecondary,
                ),
                _divider(colorScheme.outlineVariant),
                _buildDataRow(
                  RemixIcons.map_pin_2_line,
                  "lg_city".tr,
                  vehicleData['city'] ?? "---",
                  textColor,
                  textSecondary,
                ),
                _divider(colorScheme.outlineVariant),
                _buildDataRow(
                  RemixIcons.dashboard_3_line,
                  "lg_odometro".tr,
                  "${vehicleData['initial_odometer'] ?? 0} km",
                  textColor,
                  textSecondary,
                ),
                _divider(colorScheme.outlineVariant),
                _buildDataRow(
                  RemixIcons.gas_station_line,
                  "lg_tanque".tr,
                  "${vehicleData['tank_capacity'] ?? 0} L",
                  textColor,
                  textSecondary,
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(
    String nome,
    String email,
    String? fotoUrl,
    Color text,
    Color secondary,
    Color primary,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary.withOpacity(0.5), width: 3),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: primary.withOpacity(0.1),
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
            child: fotoUrl == null
                ? Icon(RemixIcons.user_3_fill, size: 45, color: primary)
                : null,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          nome,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: secondary,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyGrid(
    HomeController home,
    SettingController settings,
    Color cardColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Média Mensal",
            settings.formatarConsumo(home.gastoPorKmReal),
            Colors.green,
            cardColor,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            "Custo/Km",
            settings.formatarCurrency(home.averageCostPerKm),
            Colors.orange,
            cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverRankCard(
    Color cardColor,
    Color primary,
    Color text,
    Color secondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(RemixIcons.medal_line, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Motorista Nível ${controller.nivelAtual}",
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "XP Atual: ${controller.nivelAtual}",
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.progressoDoNivel,
              backgroundColor: primary.withOpacity(0.1),
              color: primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color accent,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primary),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(
    IconData icon,
    String label,
    String value,
    Color text,
    Color secondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: secondary, size: 20),
          const SizedBox(width: 15),
          Text(label, style: TextStyle(color: secondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) =>
      Divider(height: 1, color: color, indent: 20, endIndent: 20);

  PreferredSizeWidget _buildAppbar(Color text) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'lg_meu_painel'.tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: text,
        ),
      ),
      centerTitle: true,
    );
  }
}
