import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_alert_card.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_list_filter_menu.dart';
import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/modules/home/pages/widget/fuel_card.dart';
import 'package:fuel_tracker_app/modules/settings/controller/setting_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final settings = Get.find<SettingController>();

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
          Obx(() {
            final alerta = settings.alertaVencimento();
            if (alerta == null) return SizedBox.shrink();

            return Card(
              color: Colors.amber.shade100,
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.amber.shade900),
                title: Text(
                  alerta,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                subtitle: Text(
                  "Consulte o site do Bradesco ou Sefaz-RJ para pagar",
                ),
              ),
            );
          }),
          _buildSearchBar(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchInitialData(),
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

      final query = controller.searchText.value.toLowerCase();

      final filteredEntries = controller.filteredFuelEntries.where((e) {
        return e.vehicleId.toLowerCase().contains(query) ||
            e.gasStationId.toLowerCase().contains(query);
      }).toList();

      final meusRegistros = filteredEntries
          .where((e) => e.user == controller.currentUserId)
          .toList();

      final compartilhadoComigo = filteredEntries
          .where((e) => e.user != controller.currentUserId)
          .toList();

      if (filteredEntries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(RemixIcons.ghost_line, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Nenhum registro encontrado",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }

      return CustomScrollView(
        slivers: [
          if (meusRegistros.isNotEmpty) ...[
            _buildSliverSectionHeader("Todos os Abastecimentos", theme),
            _buildSliverEntryList(meusRegistros, theme),
          ],

          if (compartilhadoComigo.isNotEmpty) ...[
            _buildSliverSectionHeader("Compartilhado", theme),
            _buildSliverEntryList(compartilhadoComigo, theme),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ],
      );
    });
  }

  Widget _buildSliverSectionHeader(String title, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverEntryList(List<FuelEntryModel> entries, ThemeData theme) {
    final grouped = _groupEntries(entries);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        String date = grouped.keys.elementAt(i);
        List<FuelEntryModel> dayEntries = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(date, theme),
            ...dayEntries.map((e) {
              return FuelCard(entry: e, controller: controller);
            }),
          ],
        );
      }, childCount: grouped.keys.length),
    );
  }

  Map<String, List<FuelEntryModel>> _groupEntries(List<FuelEntryModel> list) {
    Map<String, List<FuelEntryModel>> map = {};

    for (var e in list) {
      if (e.entryDate == null) continue;
      String key = _formatDateKey(e.entryDate!);
      (map[key] ??= []).add(e);
    }
    return map;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) return "Hoje";
    if (entryDate == yesterday) return "Ontem";
    return DateFormat(
      'dd [MMMM]',
      'pt_BR',
    ).format(date).replaceAll('[', 'de ').replaceAll(']', '');
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              "MÉDIA GERAL",
              settings.formatarConsumo(controller.consumoMediaGeral),
            ),
            const VerticalDivider(color: Colors.white10, width: 30),
            _statTile(
              RemixIcons.gas_station_line,
              Colors.orangeAccent,
              "CUSTO MÉDIO",
              settings.formatarCurrency(controller.custoMedioGeral),
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
          onPressed: () => controller.fetchInitialData(),
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
