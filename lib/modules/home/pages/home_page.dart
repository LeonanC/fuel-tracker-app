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
      body: RefreshIndicator(
        onRefresh: () => controller.fetchInitialData(),
        edgeOffset: 100,
        color: Colors.blueAccent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroStats(),
                  _buildAlertSection(theme),
                  FuelAlertCard(),
                  _buildSearchBar(theme),
                ],
              ),
            ),
            _buildMainList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, theme),
    );
  }

  Widget _buildAlertSection(ThemeData theme) {
    return Obx(() {
      final alerta = settings.alertaVencimento();
      if (alerta == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.2)),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(RemixIcons.error_warning_line, color: Colors.amber),
          title: Text(
            alerta,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: Text(
            'Consulte Bradesco ou Sefaz-RJ para pagamento.',
            style: const TextStyle(fontSize: 11),
          ),
        ),
      );
    });
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      stretch: true,
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          'hp_titulo'.tr,
          style: GoogleFonts.montserrat(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(RemixIcons.refresh_line, size: 20),
          onPressed: () => controller.fetchInitialData(),
        ),
        FuelListFilterMenu(),
        IconButton(
          icon: Icon(RemixIcons.information_line, size: 20),
          onPressed: () => Get.toNamed('/about'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => controller.navigateToAddEntry(Get.context!),
      elevation: 4,
      highlightElevation: 8,
      backgroundColor: Colors.blueAccent,
      icon: Icon(RemixIcons.add_line, color: Colors.white),
      label: Text(
        'NOVO REGISTRO',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1,
          color: Colors.white
        ),
      ),
    );
  }

  Widget _buildMainList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(child: _buildLoadingShimmer(theme));
      }

      final query = controller.searchText.value.toLowerCase();
      final filteredEntries = controller.filteredFuelEntries.where((e) {
        return e.vehicleId.toLowerCase().contains(query) ||
            e.gasStationId.toLowerCase().contains(query);
      }).toList();

      if (filteredEntries.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(theme),
        );
      }

      final meusRegistros = filteredEntries
          .where((e) => e.user == controller.currentUserId)
          .toList();
      final compartilhado = filteredEntries
          .where((e) => e.user != controller.currentUserId)
          .toList();

      return SliverList(
        delegate: SliverChildListDelegate([
          if (meusRegistros.isNotEmpty) ...[
            _buildSectionHeader("Meus Abastecimentos", theme),
            ..._buildGroupedList(meusRegistros, theme),
          ],

          if (compartilhado.isNotEmpty) ...[
            _buildSectionHeader("Compartilhados", theme),
            ..._buildGroupedList(compartilhado, theme),
          ],
        ]),
      );
    });
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.8),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(
    List<FuelEntryModel> entries,
    ThemeData theme,
  ) {
    final grouped = _groupEntries(entries);
    List<Widget> children = [];

    for (var date in grouped.keys) {
      children.add(_sectionDateHeader(date, theme));
      children.addAll(
        grouped[date]!.map((e) => FuelCard(entry: e, controller: controller)),
      );
    }

    return children;
  }

  Widget _sectionDateHeader(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            RemixIcons.gas_station_fill,
            size: 64,
            color: theme.disabledColor.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "Nenhum registro encontrado",
            style: TextStyle(
              color: theme.disabledColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    return DateFormat('dd MMMM, yyyy', 'pt_BR').format(date);
  }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: theme.cardColor,
        highlightColor: theme.highlightColor,
        child: Column(
          children: List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
          )),
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D3238), Color(0xFF161A1D)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statTile(
                RemixIcons.dashboard_3_line,
                Colors.blueAccent,
                "MÉDIA GERAL",
                settings.formatarConsumo(controller.consumoMediaGeral),
              ),
              VerticalDivider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
                indent: 5,
                endIndent: 5,
              ),
              _statTile(
                RemixIcons.coins_line,
                Color(0xFF007268),
                "CUSTO MÉDIO",
                settings.formatarCurrency(controller.custoMedioGeral),
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
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(RemixIcons.search_line, size: 18),
          filled: true,
          fillColor: theme.cardColor.withOpacity(0.5),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
