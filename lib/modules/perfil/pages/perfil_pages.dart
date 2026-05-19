import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/perfil/controller/perfil_controller.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
    final Color textColor = theme.colorScheme.onSurface;
    final Color textSecondary = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }
        final user = controller.userModel.value;
        if (user == null) return const SizedBox.shrink();

        final String vehicleId = user.vehicle ?? "";
        final vehicleData = homeController.veiculosMap[vehicleId] ?? {};

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(user, theme, colorScheme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
                child: Column(
                  children: [
                    _buildStatGrid(
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
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      "Informações da Conta",
                      RemixIcons.user_settings_line,
                      colorScheme.primary,
                    ),
                    _buildDataCard(surfaceColor, [
                      _buildDataRow(
                        RemixIcons.user_3_line,
                        "lg_nome_completo".tr,
                        user.nome,
                        textColor,
                        textSecondary,
                      ),
                      _divider(colorScheme.outlineVariant),
                      _buildDataRow(
                        RemixIcons.phone_line,
                        "lg_telefone".tr,
                        user.telefone,
                        textColor,
                        textSecondary,
                      ),
                      _divider(colorScheme.outlineVariant),
                      _buildDataRow(
                        RemixIcons.map_pin_user_line,
                        "lg_modelo".tr,
                        vehicleData['model']?.toString() ?? "---",
                        textColor,
                        textSecondary,
                      ),
                      _divider(colorScheme.outlineVariant),
                      _buildDataRow(
                        RemixIcons.map_pin_user_line,
                        "lg_make".tr,
                        vehicleData['make']?.toString() ?? "---",
                        textColor,
                        textSecondary,
                      ),
                      _divider(colorScheme.outlineVariant),
                      _buildDataRow(
                        RemixIcons.car_line,
                        "lg_nickname".tr,
                        vehicleData['nickname']?.toString() ?? "---",
                        textColor,
                        textSecondary,
                      ),
                      _divider(colorScheme.outlineVariant),
                      _buildDataRow(
                        RemixIcons.calendar_event_line,
                        "lg_member_since".tr,
                        (user != null && user.criadoEm != null)
                            ? DateFormat(
                                'yyyy',
                              ).format(DateTime.parse(user.criadoEm.toString()))
                            : "---",
                        textColor,
                        textSecondary,
                      ),
                    ]),
                    const SizedBox(height: 25),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(
    UserModel2 user,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground, StretchMode.blurBackground],
        centerTitle: false,
        title: Text(
          user.nome,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildAvatar(user.fotoUrl, colorScheme.primary),
            const SizedBox(height: 15),
            Text(
              user.email,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imagem, Color primary) {
    bool isLocalFile = imagem != null && imagem.startsWith('/');
    bool isNetwork = imagem != null && imagem.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withOpacity(0.2), width: 2),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: primary.withOpacity(0.1),
        backgroundImage: isLocalFile
            ? FileImage(File(imagem))
            : (isNetwork ? NetworkImage(imagem) : null) as ImageProvider?,
        child: imagem == null
            ? Icon(RemixIcons.user_3_fill, size: 40, color: primary)
            : null,
      ),
    );
  }

  Widget _buildDriverRankCard(cardColor, primary, text, secondary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(RemixIcons.trophy_fill, color: Colors.amber, size: 30),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${'lg_driver_level'.tr} ${controller.nivelAtual}",
                      style: GoogleFonts.montserrat(
                        color: text,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'lg_I_dont_have_enough_XP_to_level_up'.tr,
                      style: GoogleFonts.montserrat(
                        color: secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.progressoDoNivel,
              backgroundColor: primary.withOpacity(0.1),
              color: Colors.green,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(home, settings, Color cardColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "hp_total_accumulated".tr,
            settings.formatarCurrency(home.totalGastoNoMes),
            Colors.green,
            cardColor,
            RemixIcons.money_dollar_circle_line,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            "hp_general_media".tr,
            settings.formatarConsumo(home.consumoMediaGeral),
            Colors.blueAccent,
            cardColor,
            RemixIcons.dashboard_3_line,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color accent,
    Color cardColor,
    icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 12),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(title, icon, primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.5,
              color: primary,
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
}
