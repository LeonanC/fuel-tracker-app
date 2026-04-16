// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/global/fuel_alert_card.dart';
import 'package:fuel_tracker_app/data/global/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildHeroStats(),
          FuelAlertCard(),
          _buildSearchBar(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.setupFuelStream(),
              child: _buildMainList(theme),
            ),
          ),
        ],
      ),

      floatingActionButton: _buildFAB(context, theme),
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => controller.navigateToAddEntry(context),
      backgroundColor: Colors.blueAccent,
      icon: Icon(RemixIcons.gas_station_line),
      label: Text(
        'Novo registro',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMainList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) return _buildLoadingShimmer(theme);
      final entries = controller.filteredFuelEntries;
      if (entries.isEmpty) {
        return const Center(child: Text("Nenhum registro encontrado"));
      }

      final grouped = _groupEntries(entries);

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: grouped.keys.length,
        itemBuilder: (context, i) {
          String date = grouped.keys.elementAt(i);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(date, theme),
              ...grouped[date]!.map(
                (e) => FuelCard(entry: e, controller: controller),
              ),
            ],
          );
        },
      );
    });
  }

  Map<String, List<FuelEntryModel>> _groupEntries(List<FuelEntryModel> list) {
    Map<String, List<FuelEntryModel>> map = {};

    for (var e in list) {
      String key = _formatDateKey(e.entryDate);
      (map[key] ??= []).add(e);
    }
    return map;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) return "Hoje";
    if (date.day == now.subtract(const Duration(days: 1)).day) return "Ontem";
    return DateFormat('dd MMMM', 'pt_BR').format(date);
  }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: theme.cardColor,
        highlightColor: theme.highlightColor,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 1.5,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _statTile(
              RemixIcons.calculator_line,
              Colors.blueAccent,
              "Consumo",
              controller.settingsController.formatarConsumo(
                controller.gastoPorKmReal,
              ),
            ),
            const VerticalDivider(color: Colors.white10, width: 30),
            _statTile(
              RemixIcons.gas_station_line,
              Colors.orangeAccent,
              "Custo/KM",
              controller.settingsController.formatarCurrency(
                controller.averageCostPerKm / 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.firaCode(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(
            RemixIcons.search_2_line,
            color: Colors.blueAccent,
            size: 20,
          ),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'hp_titulo'.tr,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(RemixIcons.refresh_line),
          tooltip: 'hp_refresh'.tr,
          onPressed: () => controller.setupFuelStream(),
        ),
        FuelListFilterMenu(),
        IconButton(
          icon: Icon(Icons.info_outline),
          tooltip: 'ab_about'.tr,
          onPressed: () => Get.toNamed('/about'),
        ),
      ],
    );
  }
}
