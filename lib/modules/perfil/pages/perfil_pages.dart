import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class PerfilPage extends GetView<PerfilController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeController = Get.find<HomeController>();
    final settingsController = Get.find<SettingController>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppbar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }
        final user = controller.userModel.value;

        final vehicleData = homeController.veiculosMap[user!.vehicle] ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(user.nome, user.email),
              const SizedBox(height: 25),
              _buildEfficiencyGrid(homeController, settingsController),
              const SizedBox(height: 25),
              _buildDriverRankCard(),
              const SizedBox(height: 25),
              _buildSectionHeader("lg_veiculo_ativo".tr, RemixIcons.truck_line),
              _buildDataCard([
                _buildDataRow(
                  RemixIcons.copyright_line,
                  "lg_marca".tr,
                  vehicleData['make'] ?? "---",
                ),
                _buildDataRow(
                  RemixIcons.settings_3_line,
                  "lg_modelo".tr,
                  vehicleData['model'] ?? "---",
                ),
                _buildDataRow(
                  RemixIcons.hashtag,
                  "lg_placa".tr,
                  vehicleData['plate'] ?? "---",
                ),
                _buildDataRow(
                  RemixIcons.map_pin_2_line,
                  "lg_city".tr,
                  vehicleData['city'] ?? "---",
                ),
                _buildDataRow(
                  RemixIcons.dashboard_3_line,
                  "lg_odometro".tr,
                  "${vehicleData['initial_odometer'] ?? 0} km",
                ),
                _buildDataRow(
                  RemixIcons.gas_station_line,
                  "lg_tanque".tr,
                  "${vehicleData['tank_capacity'] ?? 0} L",
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(String nome, String email) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(
            RemixIcons.user_3_fill,
            size: 40,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          nome,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(email, style: TextStyle(fontSize: 13, color: Colors.white54)),
      ],
    );
  }

  Widget _buildEfficiencyGrid(HomeController home, SettingController settings) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          "Média Mensal",
          settings.formatarConsumo(home.averageConsumption),
          Colors.greenAccent,
        ),
        _buildStatCard(
          "Custo/Km",
          settings.formatarCurrency(home.averageCostPerKm),
          Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildDriverRankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (Colors.blueAccent).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(RemixIcons.medal_line, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                controller.nivelAtual >= 10
                    ? "Motorista Ouro"
                    : "Motorista Prata",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                "Nível ${controller.nivelAtual}",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: controller.progressoDoNivel,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 16),
          Text(
            "Faltam ${controller.xpRestante.toInt()} XP para o próximo nível",
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(
            icon,
            color: isWarning ? Colors.redAccent : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 15),
          Text(label, style: TextStyle(color: Colors.white54)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'lg_meu_painel'.tr,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
    );
  }
}
