import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_alert_card.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_card.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final settings = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _buildFAB(context, theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchData(),
        edgeOffset: 100,
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(theme, colorScheme),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeroStats(),
                    FuelAlertCard(),
                    _buildSearchBar(theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildMainList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: true,
      pinned: true,
      elevation: 0,
      stretch: true,
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 20),
        centerTitle: false,
        title: Text(
          'hp_titulo'.tr,
          style: GoogleFonts.inter(
            color: theme.textTheme.displaySmall?.color,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        FuelListFilterMenu(),
        IconButton(
          padding: const EdgeInsets.all(12),
          icon: Icon(
            RemixIcons.information_line,
            size: 24,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Get.toNamed('/about'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3366FF), Color(0xFF0039E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0039E6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToAddEntry(context),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RemixIcons.add_line, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'hp_new_registry'.tr.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainList(ThemeData theme) {
    return Obx(() {
      final entries = controller.filteredFuelEntries;

      if (entries.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(theme),
        );
      }

      final fuelsAgrupadas = _agruparFuelPorData(entries);
      final datas = fuelsAgrupadas.keys.toList();

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final dataFormatada = datas[index];
            final fuelsDoDia = fuelsAgrupadas[dataFormatada]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(theme, dataFormatada),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: fuelsDoDia
                        .map(
                          (fuel) => FuelCard(
                            entry: fuel,
                            controller: controller,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          }, childCount: datas.length),
        ),
      );
    });
  }

  Map<String, List<FuelEntryModel>> _agruparFuelPorData(
    List<FuelEntryModel> fuels,
  ) {
    Map<String, List<FuelEntryModel>> grupos = {};

    for (var fuel in fuels) {
      String dataFormatada;
      DateTime hoje = DateTime.now();
      DateTime dataFuel = fuel.entryDate!;

      if (DateFormat('dd-MM-yyyy').format(dataFuel) ==
          DateFormat('dd-MM-yyyy').format(hoje)) {
        dataFormatada = "Hoje";
      } else if (DateFormat('dd-MM-yyyy').format(dataFuel) ==
          DateFormat(
            'dd-MM-yyyy',
          ).format(hoje.subtract(const Duration(days: 1)))) {
        dataFormatada = "Ontem";
      } else {
        dataFormatada = DateFormat('dd MMMM yyyy', 'pt_BR').format(dataFuel);
      }

      if (grupos[dataFormatada] == null) grupos[dataFormatada] = [];
      grupos[dataFormatada]!.add(fuel);
    }

    return grupos;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.disabledColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              RemixIcons.gas_station_fill,
              size: 72,
              color: theme.disabledColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "hp_no_vehicle_found".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: theme.disabledColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Text(
        titulo.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: theme.textTheme.bodySmall!.color!.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232931), Color(0xFF14171C)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statTile(
                RemixIcons.dashboard_3_line,
                Color(0xFF3366FF),
                "hp_general_media".tr,
                settings.formatarConsumo(controller.mediaConsumoGeral),
              ),
              VerticalDivider(
                color: Colors.white.withOpacity(0.08),
                thickness: 1,
                indent: 8,
                endIndent: 8,
              ),
              _statTile(
                RemixIcons.coins_line,
                Color(0xFF80BFA5),
                "hp_average_cost".tr,
                settings.formatarCurrency(controller.custoPorKmGeral),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(
            RemixIcons.search_line,
            size: 20,
            color: theme.dividerColor,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Color(0xFF3366FF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
